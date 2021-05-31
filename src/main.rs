#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket_contrib;
#[macro_use] extern crate diesel;

use rocket::*;
use diesel::prelude::*;
use diesel::insert_into;
use chrono::prelude::*;
use std::path::PathBuf;
use rocket_contrib::serve::StaticFiles;
use rocket_contrib::json::Json as RJson;
use std::fs::create_dir_all;
use jian_ai::schema::photos;

#[database("jian_ai")]
struct DbConn(diesel::SqliteConnection);

#[derive(Queryable, Insertable)]
#[table_name = "photos"]
struct Photo {
    datetime: Option<NaiveDateTime>,
    filename: String,
    camera_id: String,
    food_weight: i16,
    name: Option<String>
}

#[post("/new_image?<camera_id>&<food_weight>", data = "<data>")]
fn new_image(db: DbConn, camera_id: String, food_weight: i16, data: Data) -> Result<(), Box<dyn std::error::Error>> {
    use jian_ai::schema::photos::dsl as photo;
    let utc: DateTime<Utc> = Utc::now();
    let filename = format!("{}-{}.jpg", camera_id, utc.format("%Y%m%d_%H%M%S_%f"));
    let path: PathBuf = [env!("CARGO_MANIFEST_DIR"), "pics", &filename].iter().collect();
    data.stream_to_file(path)?;
    // identify -> name
    let pic = Photo { datetime: None
                    , filename: filename.clone()
                    , camera_id: camera_id
                    , food_weight: food_weight
                    , name: None };
    insert_into(photo::photos).values(&pic).execute(&*db)?;
    Ok(())
}

#[get("/<file..>")]
fn pics(file: PathBuf) -> Result<rocket::response::NamedFile, Box<dyn std::error::Error>> {
    let content = rocket::response::NamedFile::open([env!("CARGO_MANIFEST_DIR"), "pics"].iter().collect::<PathBuf>().join(file))?;
    Ok(content)
}

#[get("/names")]
fn names() -> Result<(), Box<dyn std::error::Error>> {
    Ok(())
}

#[get("/unnamed_images")]
fn unnamed_images(db: DbConn) -> Result<RJson<Vec<String>>, Box<dyn std::error::Error>> {
    use jian_ai::schema::photos::dsl as photo;
    let vec = photo::photos.filter(photo::name.is_null()).load::<Photo>(&*db)?
        .iter().map(|x| x.filename.clone()).collect();
    Ok(RJson(vec))
}

#[post("/name_image")]
fn name_image() -> Result<(), Box<dyn std::error::Error>> {Ok(())}

#[post("/new_name")]
fn new_name() -> Result<(), Box<dyn std::error::Error>> {Ok(())}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    create_dir_all([env!("CARGO_MANIFEST_DIR"), "pics"].iter().collect::<PathBuf>())?;
    rocket::ignite()
        .attach(DbConn::fairing())
        .mount("/apis", routes![new_image, names, unnamed_images, name_image, new_name])
        .mount("/pics", routes![pics]) //StaticFiles::from(concat!(env!("CARGO_MANIFEST_DIR"), "/pics")))
        .mount("/", StaticFiles::from([env!("CARGO_MANIFEST_DIR"), "webpages", "static"].iter().collect::<PathBuf>()))
        .launch();

    Ok(())
}
