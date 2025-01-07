import dotenv_gleam
import envoy
import events/events
import gleam/erlang/process
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/io
import gleam/otp/task
import gleam/result
import gleam/set
import gleeunit/should
import logging as l

import notification/ntfy

pub fn main() {
  event_run()
}

fn event_run() {
  let assert Ok(event_actor) = events.new()
  events.publish(
    event_actor,
    events.Runtime(from: "scratch", title: "title", message: "message 1"),
  )

  task.async(fn() {
    events.publish(
      event_actor,
      events.Runtime(from: "scratch", title: "title", message: "message 2"),
    )
    events.publish(
      event_actor,
      events.Runtime(from: "scratch", title: "title", message: "message 3"),
    )
  })
  let subject = events.subscribe(event_actor)
  let assert Ok(event) = process.receive(from: subject, within: 50)
  io.debug(event)
  let assert Ok(event) = process.receive(from: subject, within: 50)
  io.debug(event)
  // let assert Ok(event) = process.receive(from: subject, within: 50)
  // io.debug(event)

  process.sleep(1000)
}

fn curl(url: String) {
  // Prepare a HTTP request record
  let assert Ok(base_req) =
    request.to("https://test-api.service.hmrc.gov.uk/hello/world")

  let req =
    request.prepend_header(base_req, "accept", "application/vnd.hmrc.1.0+json")

  // Send the HTTP request to the server
  use resp <- result.try(httpc.send(req))

  // We get a response record back
  resp.status
  |> should.equal(200)

  resp
  |> response.get_header("content-type")
  |> should.equal(Ok("application/json"))

  resp.body
  |> should.equal("{\"message\":\"Hello World\"}")

  io.debug(resp)
  Ok(resp)
}

fn dot_env() {
  io.println("----------------SCRATCHPAD----------------")
  io.debug(envoy.get("APP_ENV"))
  io.debug(envoy.get("NTFY_TOPIC"))
  io.debug(envoy.get("APP_NAME"))
  io.debug(envoy.get("FLY_REGION"))

  dotenv_gleam.config()
  io.debug(envoy.get("APP_ENV"))
  io.debug(envoy.get("NTFY_TOPIC"))
  io.debug(envoy.get("APP_NAME"))
  io.debug(envoy.get("FLY_REGION"))
}

fn send_notification() {
  let assert Ok(ctx) = ntfy.init()
  ntfy.send(ctx, "bob", "bob", ntfy.PriorityDefault)
}
