use yew_router::prelude::*;

#[derive(Switch, Debug, Clone)]
pub enum Route {
    #[to = "/tagging"]
    TaggingPage,
    #[to = "/new_tag"]
    NewTagPage,
}
