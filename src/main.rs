#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket_contrib;
#[macro_use] extern crate diesel;

use rocket::*;
use diesel::prelude::*;
use diesel::{insert_into, update};
use chrono::prelude::*;
use std::path::PathBuf;
use rocket_contrib::serve::StaticFiles;
use rocket_contrib::json::Json as RJson;
use std::fs::create_dir_all;
use jian_ai::schema::photos;
//use jian_ai::schema::names;

#[database("jian_ai")]
struct DbConn(diesel::SqliteConnection);

#[derive(Queryable, Insertable)]
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

#[get("/names")]
fn names(db: DbConn) -> Result<RJson<Vec<String>>, Box<dyn std::error::Error>> {
    use jian_ai::schema::names::dsl as name;
    let vec = name::names.select(name::name).load(&*db)?;
    Ok(RJson(vec))
}

#[get("/unnamed_images")]
fn unnamed_images(db: DbConn) -> Result<RJson<Vec<String>>, Box<dyn std::error::Error>> {
    use jian_ai::schema::photos::dsl as photo;
    let vec = photo::photos.select(photo::filename).filter(photo::name.is_null()).load(&*db)?;
    Ok(RJson(vec))
}

#[post("/name_image?<photo_filename>&<name>")]
fn name_image(db: DbConn, photo_filename: String, name: String) -> Result<(), Box<dyn std::error::Error>> {
    use jian_ai::schema::photos::dsl as photo;
    update(photo::photos.filter(photo::filename.eq(photo_filename))).set(photos::name.eq(Some(name))).execute(&*db)?;
    Ok(())
}

#[post("/new_names?<names>")]
fn new_names(db: DbConn, names: String) -> Result<(), Box<dyn std::error::Error>> {
    use jian_ai::schema::names::dsl as name;
    names.split(',').map(|name| insert_into(name::names).values(name::name.eq(name)).execute(&*db)).collect::<QueryResult<Vec<usize>>>()?;
    Ok(())
}

// #[get("/<file..>")]
// fn pics(file: PathBuf) -> Result<rocket::response::NamedFile, Box<dyn std::error::Error>> {
//     let content = rocket::response::NamedFile::open([env!("CARGO_MANIFEST_DIR"), "pics"].iter().collect::<PathBuf>().join(file))?;
//     Ok(content)
// }

fn main() -> Result<(), Box<dyn std::error::Error>> {
    create_dir_all([env!("CARGO_MANIFEST_DIR"), "pics"].iter().collect::<PathBuf>())?;
    rocket::ignite()
        .attach(DbConn::fairing())
        .mount("/apis", routes![new_image, names, unnamed_images, name_image, new_names])
        .mount("/pics", StaticFiles::from(concat!(env!("CARGO_MANIFEST_DIR"), "/pics")))
        .mount("/", YewFiles {root: [env!("CARGO_MANIFEST_DIR"), "webpages", "static"].iter().collect::<PathBuf>(), default_page: ["index.html"].iter().collect::<PathBuf>(), rank: 100})// StaticFiles::from([env!("CARGO_MANIFEST_DIR"), "webpages", "static"].iter().collect::<PathBuf>()))
        .launch();

    Ok(())
}

use rocket::handler::Outcome;
use rocket::http::{Method, Status};
use rocket::http::uri::Segments;
use rocket::response::NamedFile;

#[derive(Clone)]
pub struct YewFiles {
    root: PathBuf,
    default_page: PathBuf,
    rank: isize
}

impl Into<Vec<Route>> for YewFiles {
    fn into(self) -> Vec<Route> {
        vec![Route::ranked(self.rank, Method::Get, "/<path..>", self.clone())]
    }
}

impl Handler for YewFiles {
    fn handle<'r>(&self, req: &'r Request<'_>, _data: Data) -> Outcome<'r> {
        if let Some(Ok(segs)) = req.get_segments::<Segments>(0) {
            if let Ok(path) = segs.into_path_buf(false) {
                let full_path = self.root.join(path);
                if full_path.is_file() {
                    Outcome::from(req, NamedFile::open(&full_path).ok())
                } else {
                    Outcome::from(req, NamedFile::open(&self.root.join(&self.default_page)).ok())
                }
            } else {
                Outcome::Failure(Status::NotFound)
            }
        } else {
            Outcome::Failure(Status::NotFound)
        }
    }
}
