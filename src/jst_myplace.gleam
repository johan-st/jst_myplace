import gleam/erlang/process
import mist
import wisp

// web specific imports
import web/router

pub fn main() {
  wisp.configure_logger()

  let secret_key_base = "secret_key_base"

  let assert Ok(_) =
    wisp.mist_handler(router.root(), secret_key_base)
    |> mist.new
    |> mist.port(8080)
    |> mist.start_http
  process.sleep_forever()
}
