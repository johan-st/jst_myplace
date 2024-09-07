import gleam/http/request
import gleam/string_builder
import logging as l
import wisp

/// global middleware is applied to all requests
pub fn global(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  // Permit browsers to simulate methods other than GET and POST using the
  // `_method` query parameter.
  let req = wisp.method_override(req)

  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  // Handle the request!
  handle_request(req)
}

pub fn require_auth_header(
  req: wisp.Request,
  _handle_request: fn(wisp.Request) -> wisp.Response,
) {
  // check if the request has a valid auth token
  // if not, return a 401 response
  case request.get_header(req, "Authorization") {
    Ok("Basic " <> token) -> {
      let _ = l.log(l.Debug, "auth token was: " <> token)
      wisp.json_response(
        string_builder.from_string("{'message': 'Authorized'}"),
        200,
      )
    }
    _ ->
      wisp.response(401)
      |> wisp.string_body(
        "401 - Not Authorized.\nAuthorization header is required. (format: 'Authorization: Basic <token>')",
      )
  }
}
