import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type ResponseData}

import pages

pub fn main() {
  let assert Ok(_) =
    web_service
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http
  process.sleep_forever()
}

fn web_service(req: Request(a)) -> Response(ResponseData) {
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
    _ -> {
      pages.from_string("404 - Not Found", 404)
    }
  }
}
