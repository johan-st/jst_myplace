//// The notifications do not need to be handled by an actor in the current implementation. 
//// Currently it holds only the configuration.
//// 
//// This is to facilitate the fiture implementation of a stateful notification system.
//// future implementation could include:
//// - Rate limiting
//// - Deduplication
//// - Delivery guarantees
//// - Per user notification preferences?
//// - others?

import gleam/erlang/process.{type Subject}
import gleam/otp/actor
import gleam/set.{type Set}
import logging as l
import gleam/io
import notification/ntfy

const timeout: Int = 2_500

pub type Notification {
  Notification(
    title: String,
    message: String,
    tags: Set(String),
    priority: l.LogLevel,
  )
}

// -------------- PUBLIC API --------------

/// Create a new notification actor.
pub fn new() -> Result(Subject(Message), actor.StartError) {
  let assert Ok(ctx) = ntfy.init()
  actor.start(ctx, handle_message)
}

/// Queue a notification to be sent.
pub fn send_notification(
  actor: Subject(Message),
  notification: Notification,
) -> Nil {
  actor.send(actor, SendNotification(notification))
}

/// Shutdown functions like this are often written for manual usage and testing purposes.
/// In a real application, you'd probably want to use a `supervisor` to manage the lifecycle of your actors.
pub fn close(actor: Subject(Message)) -> Nil {
  actor.send(actor, Shutdown)
}

/// The messages that the notification actor can receive.
pub type Message {
  SendNotification(Notification)
  Shutdown
}

// -------------- INTERNALS --------------

// This is our actor's message handler. It's a function that takes a message and the current state of the actor,
// and returns a new state for the actor to continue with.
//
// There's nothing really magic going on under the hood here. An actor is really just a recursive function that
// holds state in its arguments, receives a message, possibly does some work or send messages back to other processes, 
// and then calls itself with some new state. The `actor.Next` type is just an abstraction over that pattern.
//
// In fact, take a look at [it's definition](https://hexdocs.pm/gleam_otp/gleam/otp/actor.html#Next) 
// and you'll see what I mean.
fn handle_message(
  message: Message,
  ctx: ntfy.NtfyContext,
) -> actor.Next(Message, ntfy.NtfyContext) {
  // We pattern match on the message to decide what to do.
  case message {
    Shutdown -> actor.Stop(process.Normal)

    SendNotification(notification) -> {
      io.debug(notification)
      ntfy.send(ctx, "bob", "bob", ntfy.PriorityDefault)
      actor.continue(ctx)
    }
  }
}
