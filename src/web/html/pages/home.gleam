import lustre/element.{type Element}
import lustre/element/html.{html}
import wisp

pub fn view() -> Element(wisp.Body) {
  [
    html.h1([], [html.text("Welcome to the home page!")]),
    html.p([], [html.text("This is a simple web app written in Gleam.")]),
  ]
  |> element.fragment
}
