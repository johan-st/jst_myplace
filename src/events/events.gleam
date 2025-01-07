//// Events, this is a rudimentary event bus. It facilitates publishing and subscribing to topics.
//// Initially ment for publishing runtime events that would otherwise be logged to stdout.

import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/set.{type Set}
import logging as l

// -------------- PUBLIC API ---------------

pub type Event {
  Runtime(from: String, title: String, message: String)
}

/// Create a new event handling actor.
pub fn new() -> Result(Subject(Message), actor.StartError) {
  let state: State = State(events: [], subscribers: set.new())
  actor.start(state, handle_message)
}

pub fn publish(actor: Subject(Message), event: Event) {
  actor.send(actor, Publish(event))
}

pub fn subscribe(actor: Subject(Message)) -> Subject(Event) {
  let subject = process.new_subject()
  actor.send(actor, Subscribe(subject))
  subject
}

// -------------- INTERNALS  ---------------

pub type Message {
  Shutdown
  Publish(Event)
  Subscribe(Subject(Event))
}

type State {
  State(events: List(Event), subscribers: Set(Subject(Event)))
}

/// Handle message
fn handle_message(message: Message, state: State) -> actor.Next(Message, State) {
  case message {
    Shutdown -> {
      l.log(l.Debug, "Shutting down event handler")
      actor.Stop(process.Normal)
    }
    Publish(event) -> {
      l.log(l.Debug, "Publishing event: " <> event.title)
      state.subscribers
      |> set.map(fn(subject) { process.send(subject, event) })
      let event_list = [event, ..state.events]
      actor.continue(State(event_list, state.subscribers))
    }
    Subscribe(subject) -> {
      l.log(l.Debug, "Subscribing to events")
      let subscribers = set.insert(state.subscribers, subject)
      actor.continue(State(state.events, subscribers))
    }
  }
}
