import lustre/element.{type Element}
import lustre/element/html.{html}
import wisp

pub fn view() -> Element(wisp.Body) {
  html([], [
    html.h1([], [html.text("Welcome to the api docs!")]),
    html.p([], [html.text("todo, under construction")]),
  ])
}