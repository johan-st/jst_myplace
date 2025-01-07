import envoy
import gleam/http.{Post}
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/json
import gleam/result
import gleam/set.{type Set}
import logging as l

// const ntfy_topic: String = "laE8vqqd49kS7uep"
// const app_name: String = "jst_myplace"
// const app_env: String = "dev"

pub opaque type NtfyContext {
  NtfyContext(topic: String, app_name: String, tags: Set(String))
}

pub fn init() -> Result(NtfyContext, String) {
  let assert Ok(ntfy_topic) = envoy.get("NTFY_TOPIC")
  let assert Ok(app_name) = envoy.get("APP_NAME")
  let assert Ok(app_env) = envoy.get("APP_ENV")

  Ok(NtfyContext(
    topic: ntfy_topic,
    app_name: app_name,
    tags: set.from_list([app_name, app_env]),
  ))
}

pub fn add_tag(ctx: NtfyContext, tag: String) -> NtfyContext {
  NtfyContext(
    topic: ctx.topic,
    app_name: ctx.app_name,
    tags: set.insert(ctx.tags, tag),
  )
}

pub type NtfyPriority {
  PriorityMin
  PriorityLow
  PriorityDefault
  PriorityHigh
  PriorityUrgent
}

// ref: https://docs.ntfy.sh/publish/#action-buttons
// type NtfyAction {
//   View
//   Broadcast
//   Http
// }

// ref: https://docs.ntfy.sh/publish/#publish-as-json
pub type NtfyMessage {
  NtfyMessage(
    topic: String,
    message: String,
    title: String,
    tags: Set(String),
    priority: NtfyPriority,
    // actions: List(NtfyAction),
    // click: String,
    // attach: String,
    // markdown: Bool,
    // icon: String,
    // filename: String,
    // delay: String,
    // email: String,
    // call: String,
  )
}

pub fn send(
  context ctx: NtfyContext,
  title title: String,
  message message: String,
  priority priority: NtfyPriority,
) -> Nil {
  let msg =
    NtfyMessage(
      topic: ctx.topic,
      message: message,
      title: title,
      tags: ctx.tags,
      priority: priority,
    )

  l.log(l.Debug, "Sending notification")
  let resp = send_ntfy_notification(msg)
  io.debug(resp)
  // case result.is_ok(send_ntfy_notification(msg)) {
  //   True -> l.log(l.Debug, "Notification sent")
  //   False -> l.log(l.Error, "Failed to send notification")
  // }
  l.log(l.Debug, "Notification sent")
  Nil
}

fn send_ntfy_notification(message msg: NtfyMessage) -> Result(Nil, String) {
  // Prepare a HTTP request record
  l.log(l.Debug, "Preparing HTTP request")
  let assert Ok(base_req) = request.to("https://ntfy.sh")

  let req =
    base_req
    |> request.set_method(Post)
    |> request.set_body(ntfy_message_to_json_string(msg))
    |> request.set_header("Content-Type", "application/json")

  l.log(l.Debug, "Sending HTTP request")
  // Send the HTTP request to the server

  let resp = httpc.send(req)
  l.log(l.Debug, "Received HTTP response")
  io.debug(resp)
  case resp {
    Ok(_) -> Ok(Nil)
    Error(_) -> Error("failed to send notification")
  }
}

// ref: https://docs.ntfy.sh/publish/#publish-as-json
fn ntfy_message_to_json_string(message msg: NtfyMessage) -> String {
  let priority = case msg.priority {
    PriorityMin -> 1
    PriorityLow -> 2
    PriorityDefault -> 3
    PriorityHigh -> 4
    PriorityUrgent -> 5
  }

  json.object([
    #("topic", json.string(msg.topic)),
    #("message", json.string(msg.message)),
    #("title", json.string(msg.title)),
    #("tags", json.array(set.to_list(msg.tags), of: json.string)),
    #("priority", json.int(priority)),
  ])
  |> json.to_string
}
