import gleam/http.{Get, Post}
import web/middleware
import wisp.{type Request, type Response}

pub fn router() -> fn(Request, List(String)) -> Response {
  // Closure for setting up the router.

  fn(req: Request, path_segments: List(String)) -> Response {
    use req <- middleware.require_auth_header(req)

    case path_segments {
      ["chat"] -> chat(req)
      _ -> wisp.not_found()
    }
  }
}

fn chat(req: Request) -> Response {
  case req.method {
    Get -> todo
    Post -> todo
    _ -> wisp.method_not_allowed([Get, Post])
  }
}
