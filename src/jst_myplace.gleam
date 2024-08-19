import context
import envoy
import gleam/erlang/process
import mist
import wisp

// web specific imports
import web/router

pub fn main() {
  wisp.configure_logger()

  // Environment variables
  let secret_key_base = case envoy.get("SECRET_KEY_BASE") {
    Ok(secret_key_base) -> secret_key_base
    Error(_) -> {
      wisp.log_notice(
        "SECRET_KEY_BASE not set. using random key. (not suitable for multi-node deployment and will interfere with session management)",
      )
      wisp.random_string(64)
    }
  }

  let ctx = context.new()

  // start web server
  let assert Ok(_) =
    wisp.mist_handler(router.root(ctx), secret_key_base)
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http
  process.sleep_forever()
}
