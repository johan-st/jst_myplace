import dotenv_gleam
import envoy
import gleam/erlang/process.{type Pid}
import gleam/otp/static_supervisor as sup
import gleam/otp/task
import gleam/io
import logging as l
import scratch
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/result
import gleeunit/should

// my imports
import notification/actor as ntfy

// pub type Services {
//   Notification(notification.Subject(notification.Message))
//   // Frontend(frontend.Subject(frontend.Message))
//   // Cron(cron.Subject(cron.Message))
//   // Monitoring(monitoring.Subject(monitoring.Message))
//   // EventHub(event_hub.Subject(event_hub.Message))
//   // ResourceManager(resource_manager.Subject(resource_manager.Message))
// }

pub fn main() {
  l.configure()
  l.set_level(l.Debug)

  // dotenv_gleam.config()
  // scratch.curl("https://www.google.com")
  scratch.main()
  // run() 
}
pub fn curl(url: String) {
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

fn conf_init() {

}

fn run() {

  let assert Ok(level) = envoy.get("LOG_LEVEL")
  case level {
    "debug" -> l.set_level(l.Debug)
    "info" -> l.set_level(l.Info)
    "warn" -> l.set_level(l.Warning)
    "error" -> l.set_level(l.Error)
    _ -> l.set_level(l.Debug)
  }

  io.debug(process.self())




  // let assert Ok(sup_pid) =
  //   sup.new(sup.OneForOne)
  //   |> sup.add(sup.supervisor_child("frontend", start_frontend_supervisor(ctx_ntfy)))
  //   // |> sup.add(sup.supervisor_child("cron", start_cron_supervisor))
  //   // |> sup.add(sup.supervisor_child("monitoring", start_monitoring_supervisor))
  //   // |> sup.add(sup.supervisor_child("event_hub", start_event_hub_supervisor))
  //   // |> sup.add(sup.supervisor_child("resource_manager", start_resource_manager_supervisor))
  //   |> sup.start_link

  // l.log(l.Debug, "Supervisor started")

  // process.sleep(10_000)

  // l.log(l.Debug, "Supervisor stopped")
}

// pub fn start_frontend_supervisor(ctx_ntfy: ntfy.NtfyContext) {
//   fn() {
//     task.async(fn() {
//       // send stop notification
//       ntfy.send(
//         ctx_ntfy,
//         title: "MAIN stopped",
//         message: "MAIN supervisor is halting",
//         priority: ntfy.PriorityHigh,
//       )
//     })

//     sup.new(sup.OneForOne)
//     // |> sup.add(sup.worker_child("web", start_http_server))
//     |> sup.start_link
//   }
// }

// pub fn start_http_server() {
//   l.log(l.Debug, "Starting HTTP server")
// }

