import birl
import birl/duration.{
  type Duration, Day, Hour, MicroSecond, MilliSecond, Minute, Month, Second,
  Week, Year,
}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html.{html}
import wisp.{type Request}

pub type NavLink {
  Internal(href: String, text: String)
  External(href: String, text: String)
}

pub fn view_nav_link(link: NavLink) -> Element(wisp.Body) {
  case link {
    Internal(href, text) -> html.a([attribute.href(href)], [html.text(text)])
    External(href, text) ->
      html.a([attribute.href(href), attribute.target("_blank")], [
        html.text(text),
      ])
  }
}

pub fn view_duration(dur: Duration) -> Element(wisp.Body) {
  dur
  |> duration.decompose
  |> list.map(int_unit_to_string)
  |> list.filter(fn(s) { s != "" })
  |> list.intersperse(" ")
  |> string.concat
  |> html.text
}

fn int_unit_to_string(int_unit) -> String {
  let #(int, unit) = int_unit
  let int = int |> int.to_string

  case unit {
    Year -> string.concat([int, "y"])
    Month -> string.concat([int, "mo"])
    Week -> string.concat([int, "w"])
    Day -> string.concat([int, "d"])
    Hour -> string.concat([int, "h"])
    Minute -> string.concat([int, "m"])
    Second -> string.concat([int, "s"])
    MilliSecond -> ""
    MicroSecond -> ""
  }
}

