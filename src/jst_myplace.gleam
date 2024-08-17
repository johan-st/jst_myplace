import api
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type ResponseData}

import pages

pub fn main() {
  let assert Ok(_) =
    web_service(Nil)
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http
  process.sleep_forever()
}

fn web_service(_deps) -> fn(Request(a)) -> Response(ResponseData) {
  // closure for setup
  fn(req) -> Response(ResponseData) {
    case request.path_segments(req) {
      [] -> {
        pages.from_string("index", 200)
      }
      ["greet"] -> {
        pages.greet("stranger")
      }
      ["greet", name] -> {
        pages.greet(name)
      }
      ["api"] -> {
        pages.from_string("?api docs?", 200)
      }
      ["api", ..path_remaining] -> {
        api.router(path_remaining, req)
      }
      _ -> {
        pages.from_string("(web_service): 404 - Not Found", 404)
      }
    }
  }
}
