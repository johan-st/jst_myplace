import gleam/http.{Get, Post}
import gleam/string_builder
import web/api
import web/middleware
import web/pages
import wisp.{type Request, type Response}

pub fn root() -> fn(Request) -> Response {
  // Closure for setting up the router.
  let assert Ok(priv) = wisp.priv_directory("jst_myplace")

  let api_router = api.router()
  fn(req: Request) -> Response {
    use req <- middleware.global(req)

    case wisp.path_segments(req) {
      [] -> pages.home(req)
      // Static files
      ["static", _] -> serve_static(req, priv)
      // Content Pages
      ["api"] -> pages.api_docs(req)
      // API routes
      ["api", ..path_remaining] -> {
        use req <- middleware.require_auth_header(req)
        api_router(req, path_remaining)
      }
      _ -> wisp.not_found()
    }
  }
}

fn serve_static(req: Request, from: String) -> Response {
  use <- wisp.serve_static(req, under: "/static", from: from)

  wisp.not_found()
}

fn comments(req: Request) -> Response {
  case req.method {
    Get -> list_comments()
    Post -> create_comment(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

fn list_comments() -> Response {
  let html = string_builder.from_string("Comments!")
  wisp.ok()
  |> wisp.html_body(html)
}

fn create_comment(_req: Request) -> Response {
  let html = string_builder.from_string("Created")
  wisp.created()
  |> wisp.html_body(html)
}

fn show_comment(req: Request, id: String) -> Response {
  use <- wisp.require_method(req, Get)

  let html = string_builder.from_string("Comment with id " <> id)
  wisp.ok()
  |> wisp.html_body(html)
}
