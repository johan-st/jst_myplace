import birl
import envoy

pub opaque type ServerContext {
  ServerContext(start_time: birl.Time, region_code: String)
}

pub fn new() -> ServerContext {
  let region_string = case envoy.get("FLY_REGION") {
    Ok(region) -> region
    Error(_) -> " - env not set - "
  }

  ServerContext(start_time: birl.utc_now(), region_code: region_string)
}

pub fn start_time(ctx: ServerContext) -> birl.Time {
  ctx.start_time
}

pub fn region_code(ctx: ServerContext) -> String {
  ctx.region_code
}
