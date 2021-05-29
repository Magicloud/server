use wasm_bindgen::prelude::*;
use yew::prelude::*;

struct Tagging {}

impl Component for Tagging {
    type Message = ();
    type Properties = ();

    fn create(_: Self::Properties, _: ComponentLink<Self>) -> Self {
        Self {}
    }

    fn update(&mut self, _: Self::Message) -> ShouldRender {
        true
    }

    fn change(&mut self, _: Self::Properties) -> ShouldRender {
        true
    }

    fn view(&self) -> Html {
        html! { <span>{"Tagging World!"}</span> }
    }
}

#[wasm_bindgen(start)]
pub fn run_app() {
    App::<Tagging>::new().mount_to_body();
}
