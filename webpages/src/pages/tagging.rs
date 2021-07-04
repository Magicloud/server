use yew::prelude::*;
use serde_json::to_string;
use yew::services::fetch::*;
use yew::format::*;
use anyhow::Error;
use crate::components::*;

struct State {
    getting_tags: bool,
    get_tags_error: Option<Error>,
    tags: Vec<String>
}

pub struct TaggingPage {
    state: State,
    link: ComponentLink<Self>,
    _task: Option<FetchTask>
}

pub enum Msg {
    ToTag(String),
    GetTags,
    GetTagsOk(Vec<String>),
    GetTagsErr(Error)
}

impl Component for TaggingPage {
    type Message = Msg;
    type Properties = ();

    fn create(_: Self::Properties, link: ComponentLink<Self>) -> Self {
        link.send_message(Msg::GetTags);
        Self {
            state: State {
                getting_tags: false,
                get_tags_error: None,
                tags: vec![]
            },
            link,
            _task: None
        }
    }

    fn update(&mut self, msg: Self::Message) -> ShouldRender {
        match msg {
            Msg::GetTags => {
                self.state.getting_tags = true;
                let req = Request::get("/apis/names").body(Nothing).unwrap();
                let on_done = self.link.callback(move |response: Response<Json<Result<Vec<String>, Error>>>| {
                    let Json(data) = response.into_body();
                    match data {
                        Ok(tags) => Msg::GetTagsOk(tags.to_vec()),
                        Err(e) => Msg::GetTagsErr(e)
                    }
                });
                let task = FetchService::fetch(req, on_done).unwrap();
                self._task = Some(task);
                true
            }
            Msg::GetTagsOk(tags) => {
                self.state.getting_tags = false;
                self.state.tags = tags;
                true
            }
            Msg::GetTagsErr(e) => {
                self.state.getting_tags = false;
                self.state.get_tags_error = Some(e);
                true
            }
            Msg::ToTag(_filename) => {true} // TODO
        }
    }

    fn change(&mut self, _: Self::Properties) -> ShouldRender { true }

    fn view(&self) -> Html { html!{<>
<header> <h1>{"兼爱"}</h1> </header>
<nav class="hnav"><ul>
    <li>{"标注"}</li>
    <li>{"新名称"}</li>
</ul></nav>
<section>
    <nav>
        <PhotoList onclick=self.link.callback(move |x| Msg::ToTag(x)) />
    </nav>
    <article>
        {if self.state.getting_tags {
            html!{}
        } else {
            html!{}
        }}
        <Tagging tags_json={to_string(&self.state.tags).unwrap()} />
    </article>
</section>
<footer>{"Magicloud"}</footer>
    </>} }
}
