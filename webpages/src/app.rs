use yew::prelude::*;
use yew_router::prelude::*;
use crate::pages::*;
use crate::route::Route;

pub struct App {}

impl Component for App {
    type Message = ();
    type Properties = ();

    fn create(_: Self::Properties, _link: ComponentLink<Self>) -> Self { Self {} }
    fn update(&mut self, _msg: Self::Message) -> ShouldRender { true }
    fn change(&mut self, _: Self::Properties) -> ShouldRender { false }
    fn view(&self) -> Html {
        let render = Router::render(|switch: Route| match switch {
            Route::TaggingPage => html! {<tagging::TaggingPage />},
            Route::NewTagPage => html! {<new_tag::NewTagPage />}
        });

        html! {
            <Router<Route, ()> render=render/>
        }
    }
}
