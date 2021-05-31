table! {
    photos (filename) {
        datetime -> Nullable<Timestamp>,
        filename -> Text,
        camera_id -> Text,
        food_weight -> SmallInt,
        name -> Nullable<Text>,
    }
}
