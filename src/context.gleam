import birl
import birl/duration.{type Duration}
import envoy
import gleam/result
import wisp

pub opaque type ServerContext {
  ServerContext(
    start_time: birl.Time,
    region_code: String,
    priv_directory: String,
  )
}

pub fn new() -> ServerContext {
  let region_string = envoy.get("FLY_REGION") |> result.unwrap("N/A")


  let assert Ok(priv) = wisp.priv_directory("jst_myplace")
  let now = birl.utc_now()

  ServerContext(
    start_time: now,
    region_code: region_string,
    priv_directory: priv,
  )
}

pub fn uptime(ctx: ServerContext) -> Duration {
  case region_code(ctx) {
    "N/A" ->
      birl.difference(birl.utc_now(), ctx.start_time)
      |> duration.scale_up(100)
    _ -> birl.difference(birl.utc_now(), ctx.start_time)
  }
}

pub fn region_code(ctx: ServerContext) -> String {
  ctx.region_code
}

pub fn priv_directory(ctx: ServerContext) -> String {
  ctx.priv_directory
}
