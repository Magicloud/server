#![feature(proc_macro_hygiene, decl_macro)]

//#[macro_use] extern crate rocket;

use rocket::*;
use chrono::prelude::*;
use kv::Json as KJson;
use kv::*;
use std::path::PathBuf;
use rocket_contrib::serve::StaticFiles;
use rocket_contrib::json::Json as RJson;
use std::fs::create_dir_all;

#[derive(serde::Serialize, serde::Deserialize, PartialEq)]
struct Pic {
    datetime: DateTime<Utc>,
    filename: String,
    camera_id: String,
    food_weight_before: i16,
    food_weight_after: i16,
    tags: Vec<String>
}

#[post("/new_image?<camera_id>&<food_weight_before>&<food_weight_after>", data = "<data>")]
fn new_image(bucket: State<Bucket<'_, String, KJson<Pic>>>, camera_id: String, food_weight_before: i16, food_weight_after: i16, data: Data) -> Result<(), Box<dyn std::error::Error>> {
    let utc: DateTime<Utc> = Utc::now();
    let filename = format!("{}-{}", camera_id, utc.format("%Y%m%d_%H%M%S_%f"));
    let path: PathBuf = [env!("CARGO_MANIFEST_DIR"), "pics", &filename].iter().collect();
    data.stream_to_file(path)?;
    // identify -> tags
    let pic = Pic { datetime: utc
                  , filename: filename.clone()
                  , camera_id: camera_id
                  , food_weight_before: food_weight_before
                  , food_weight_after: food_weight_after
                  , tags: Vec::new() };
    bucket.set(format!("untagged_{}", filename), KJson(pic))?;
    Ok(())
}

#[get("/<file..>")]
fn pics(_bucket: State<Bucket<'_, String, KJson<Pic>>>, file: PathBuf) -> Result<rocket::response::NamedFile, Box<dyn std::error::Error>> {
    let content = rocket::response::NamedFile::open([env!("CARGO_MANIFEST_DIR"), "pics"].iter().collect::<PathBuf>().join(file))?;
    Ok(content)
}

#[get("/tags")]
fn tags(bucket: State<Bucket<'_, String, KJson<Pic>>>) -> Result<(), Box<dyn std::error::Error>> {
    Ok(())
}

#[get("/untagged_images")]
fn untagged_images(bucket: State<Bucket<'_, String, KJson<Pic>>>) -> Result<RJson<Vec<String>>, Box<dyn std::error::Error>> {
    let vec: Result<Vec<String>, kv::Error> = bucket.iter_prefix("untagged_").map(|x| Ok(x?.value::<KJson<Pic>>()?.0.filename)).collect();
    let vec = vec?;
    Ok(RJson(vec))
}

#[post("/tag_image")]
fn tag_image(bucket: State<Bucket<'_, String, KJson<Pic>>>) -> Result<(), Box<dyn std::error::Error>> {Ok(())}

#[post("/new_tag")]
fn new_tag(bucket: State<Bucket<'_, String, KJson<Pic>>>) -> Result<(), Box<dyn std::error::Error>> {Ok(())}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let bucket = Store::new(kv::Config::new("jian.ai"))?.bucket::<String, KJson<Pic>>(Some("jian_ai"))?;

    create_dir_all([env!("CARGO_MANIFEST_DIR"), "pics"].iter().collect::<PathBuf>())?;
    rocket::ignite()
        .manage(bucket)
        .mount("/apis", routes![new_image, tags, untagged_images, tag_image, new_tag])
        .mount("/pics", routes![pics]) //StaticFiles::from(concat!(env!("CARGO_MANIFEST_DIR"), "/pics")))
        .mount("/", StaticFiles::from([env!("CARGO_MANIFEST_DIR"), "webpages", "static"].iter().collect::<PathBuf>()))
        .launch();

    Ok(())
}
