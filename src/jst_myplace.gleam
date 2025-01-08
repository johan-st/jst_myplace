import dotenv_gleam
import envoy
import gleam/dynamic
import gleam/erlang/atom
import gleam/erlang/node
import gleam/erlang/os
import gleam/erlang/process.{type Pid}
import gleam/http/request
import gleam/http/response.{Response}
import gleam/httpc
import gleam/io
import gleam/bytes_tree
import gleam/list
import gleam/option
import gleam/otp/actor
import gleam/otp/static_supervisor as sup
import gleam/otp/supervisor
import gleam/otp/task
import gleam/result
import gleam/string
import gleeunit/should
import logging as l
import mist
import vendor/nessie_cluster
import scratch

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
  // scratch.main()
  dns_cluster_discovery()
  // run() 
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

fn dns_cluster_discovery() {
  let dns_query = case envoy.get("FLY_APP_NAME") {
    Ok(app_name) -> nessie_cluster.DnsQuery(app_name <> ".internal")
    Error(Nil) -> nessie_cluster.Ignore
  }

  let cluster = nessie_cluster.with_query(nessie_cluster.new(), dns_query)
  let cluster_worker = fn(_) { nessie_cluster.start_spec(cluster, option.None) }

  // Initialize web server
  let web =
    web_service
    |> mist.new()
    |> mist.bind("0.0.0.0")
    |> mist.port(8080)

  let web_worker = fn(_) {
    web
    |> mist.start_http()
    |> result.map_error(fn(e) { actor.InitCrashed(dynamic.from(e)) })
  }

  let assert Ok(_) =
    supervisor.start(fn(children) {
      children
      |> supervisor.add(supervisor.worker(cluster_worker))
      |> supervisor.add(supervisor.worker(web_worker))
    })

  process.sleep_forever()
}

fn web_service(_request) {
  let nodes =
    node.visible()
    |> list.map(fn(a) { atom.to_string(node.to_atom(a)) })
    |> string.join(", ")

  let me = atom.to_string(node.to_atom(node.self()))

  // let res = bytes_builder.from_string("me: " <> me <> "\npeers: " <> nodes)
  let res = bytes_tree.from_string("me: " <> me <> "\npeers: " <> nodes)

  Response(200, [], mist.Bytes(res))
}
