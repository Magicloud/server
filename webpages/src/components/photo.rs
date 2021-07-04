use yew::prelude::*;
use yew::services::fetch::*;
use yew::format::*;
use yew::agent::*;
use anyhow::Error;
use crate::event_buses::*;

pub struct Photo {
    state: State,
    task: Option<FetchTask>,
    props: Props,
    link: ComponentLink<Self>,
    event_bus_out: Dispatcher<ListToDetailEventBus>,
    event_bus_in: Box<dyn Bridge<DetailToListEventBus>>,
    event_bus_list: Dispatcher<ItemToListEventBus>
}

enum UpdateStatus {
    NotYet,
    Doing,
    Failed,
    Succeeded
}
impl ToString for UpdateStatus {
    fn to_string(&self) -> String {
        match self {
            UpdateStatus::NotYet => {"notyet"}
            UpdateStatus::Doing => {"doing"}
            UpdateStatus::Failed => {"failed"}
            UpdateStatus::Succeeded => {"succeeded"}
        }.to_string()
    }
}

struct State {
    tag: Option<String>,
    update_status: UpdateStatus
}

pub enum Msg {
    ToTag,
    Done(Option<String>),
    UpdatedOk,
    UpdatedErr(Error)
}

#[derive(Clone, Properties)]
pub struct Props {
    pub photo: String,
}

impl Component for Photo {
    type Message = Msg;
    type Properties = Props;

    fn create(props: Self::Properties, link: ComponentLink<Self>) -> Self {
        Self {
            state: State {
                tag: None,
                update_status: UpdateStatus::NotYet
            },
            task: None,
            props,
            event_bus_in: DetailToListEventBus::bridge(link.callback(Msg::Done)),
            link,
            event_bus_out: ListToDetailEventBus::dispatcher(),
            event_bus_list: ItemToListEventBus::dispatcher()
        }
    }
    fn update(&mut self, msg: Self::Message) -> ShouldRender {
        match msg {
            Msg::ToTag => {
                self.event_bus_out.send(ListToDetailEvents::ToTag(self.props.photo.clone()));
                true
            }
            Msg::Done(None) => {
                self.event_bus_list.send(ItemToListEvents::Next);
                true
            }
            Msg::Done(Some(tag)) => {
                self.state.update_status = UpdateStatus::Doing;
                let req = Request::post(format!("/apis/name_image?photo_filename={}&name={}", self.props.photo, tag)).body(Nothing).unwrap();
                let on_done = self.link.callback(move |response: Response<Result<String, Error>>| {
                    if response.status().is_success() {
                        Msg::UpdatedOk
                    } else {
                        Msg::UpdatedErr(response.into_body().err().unwrap())
                    }
                });
                let task = FetchService::fetch(req, on_done).unwrap();
                self.task = Some(task);
                self.event_bus_list.send(ItemToListEvents::Next);
                true
            }
            Msg::UpdatedOk => {
                self.state.update_status = UpdateStatus::Succeeded;
                true
            }
            Msg::UpdatedErr(_e) => {
                self.state.update_status = UpdateStatus::Failed;
                true
            }
        }
    }
    fn change(&mut self, _: Self::Properties) -> ShouldRender { true }
    fn view(&self) -> Html {
        html! {<img class={self.state.update_status.to_string()} src={format!("/pics/{}", self.props.photo)} loading="lazy" onclick=self.link.callback(move |_| Msg::ToTag) />}
    }
}
