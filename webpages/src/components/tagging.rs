use yew::prelude::*;
use serde_json::from_str;
use yew::agent::*;
use crate::event_buses::*;

pub struct Tagging {
    state: State,
    props: Props,
    link: ComponentLink<Self>,
    event_bus_in: Box<dyn Bridge<ListToDetailEventBus>>,
    event_bus_out: Dispatcher<DetailToListEventBus>
}

struct State {
    photo: Option<String>,
    tags: Vec<String>,
    value: String
}

pub enum Msg {
    Save,
    Cancel,
    ToTag(String),
    UITagValueState(ChangeData)
}

#[derive(Clone, Properties)]
pub struct Props {
    pub tags_json: String
}

impl Component for Tagging {
    type Message = Msg;
    type Properties = Props;

    fn create(props: Self::Properties, link: ComponentLink<Self>) -> Self {
        Self {
            state: State {
                photo: None,
                tags: from_str(&props.tags_json).unwrap(),
                value: "".to_string()
            },
            props,
            event_bus_in: ListToDetailEventBus::bridge(link.callback(Msg::ToTag)),
            link,
            event_bus_out: DetailToListEventBus::dispatcher()
        }
    }
    fn update(&mut self, msg: Self::Message) -> ShouldRender {
        match msg {
            Msg::Save => {
                self.event_bus_out.send(DetailToListEvents::Done(Some(self.state.value.clone())));
                false
            }
            Msg::Cancel => {
                self.event_bus_out.send(DetailToListEvents::Done(None));
                false
            }
            Msg::ToTag(filename) => {
                self.state.photo = Some(filename);
                true
            }
            Msg::UITagValueState(v) => {
                match v {
                    ChangeData::Value(v) => { self.state.value = v }
                    ChangeData::Select(_) => {}
                    ChangeData::Files(_) => {}
                }
                false
            }
        }
    }
    fn change(&mut self, _: Self::Properties) -> ShouldRender { true }
    fn view(&self) -> Html {
        if let Some(photo) = &self.state.photo {
            html! {<>
                <img src={format!("/pics/{}", photo)} />
                <input type="text" list="tags" value={self.state.value.clone()} onchange=self.link.callback( move |v| Msg::UITagValueState(v)) />
                <datalist id="tags">
                    {self.state.tags.iter().map(|tag| html! {<option>{tag}</option>}).collect::<Html>()}
                </datalist>
                <button type="button" onclick=self.link.callback(move |_| Msg::Save)>{"Save & Next"}</button>
                <button type="button" onclick=self.link.callback(move |_| Msg::Cancel)>{"Cancel & Next"}</button>
            </>}
        } else {
            html!{}
        }
    }
}
