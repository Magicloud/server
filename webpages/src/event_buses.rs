use std::collections::HashSet;
use yew::worker::*;

pub enum ListToDetailEvents {
    ToTag(String)
}

pub struct ListToDetailEventBus {
    link: AgentLink<ListToDetailEventBus>,
    subscribers: HashSet<HandlerId>,
}

impl Agent for ListToDetailEventBus {
    type Reach = Context<Self>;
    type Message = ();
    type Input = ListToDetailEvents;
    type Output = String;

    fn create(link: AgentLink<Self>) -> Self {
        Self {
            link,
            subscribers: HashSet::new()
        }
    }

    fn update(&mut self, _msg: Self::Message) {}

    fn handle_input(&mut self, msg: Self::Input, _id: HandlerId) {
        match msg {
            ListToDetailEvents::ToTag(filename) => {
                for sub in self.subscribers.iter() {
                    self.link.respond(*sub, filename.clone());
                }
            }
        }
    }

    fn connected(&mut self, id: HandlerId) {
        self.subscribers.insert(id);
    }

    fn disconnected(&mut self, id: HandlerId) {
        self.subscribers.remove(&id);
    }
}

pub enum DetailToListEvents {
    Done(Option<String>)
}

pub struct DetailToListEventBus {
    link: AgentLink<DetailToListEventBus>,
    subscribers: HashSet<HandlerId>,
}

impl Agent for DetailToListEventBus {
    type Reach = Context<Self>;
    type Message = ();
    type Input = DetailToListEvents;
    type Output = Option<String>;

    fn create(link: AgentLink<Self>) -> Self {
        Self {
            link,
            subscribers: HashSet::new()
        }
    }

    fn update(&mut self, _msg: Self::Message) {}

    fn handle_input(&mut self, msg: Self::Input, _id: HandlerId) {
        match msg {
            DetailToListEvents::Done(done) => {
                for sub in self.subscribers.iter() {
                    self.link.respond(*sub, done.clone());
                }
            }
        }
    }

    fn connected(&mut self, id: HandlerId) {
        self.subscribers.insert(id);
    }

    fn disconnected(&mut self, id: HandlerId) {
        self.subscribers.remove(&id);
    }
}

pub enum ItemToListEvents {
    Next
}

pub struct ItemToListEventBus {
    link: AgentLink<ItemToListEventBus>,
    subscribers: HashSet<HandlerId>,
}

impl Agent for ItemToListEventBus {
    type Reach = Context<Self>;
    type Message = ();
    type Input = ItemToListEvents;
    type Output = ();

    fn create(link: AgentLink<Self>) -> Self {
        Self {
            link,
            subscribers: HashSet::new()
        }
    }

    fn update(&mut self, _msg: Self::Message) {}

    fn handle_input(&mut self, msg: Self::Input, _id: HandlerId) {
        match msg {
            ItemToListEvents::Next => {
                for sub in self.subscribers.iter() {
                    self.link.respond(*sub, ());
                }
            }
        }
    }

    fn connected(&mut self, id: HandlerId) {
        self.subscribers.insert(id);
    }

    fn disconnected(&mut self, id: HandlerId) {
        self.subscribers.remove(&id);
    }
}
