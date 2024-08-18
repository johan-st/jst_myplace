import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type ResponseData}
import pages

pub fn router(
  path_remaining: List(String),
  _req: Request(a),
) -> Response(ResponseData) {
  case path_remaining {
    [object] -> {
      pages.from_string("req to " <> object, 200)
    }
    _ -> {
      pages.from_string("(api): 404 - Not Found", 404)
    }
  }
}
