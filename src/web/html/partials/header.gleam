import gleam/list
import lustre/element.{type Element}
import lustre/element/html.{html}
import web/html/partials/utils.{Internal, view_nav_link}
import wisp

pub fn view() -> Element(wisp.Body) {
  let nav_links = [
    Internal("/", "Home"),
    Internal("/blog", "Blog"),
    Internal("/api", "API Docs"),
  ]
  html.header([], [
    html.h1([], [html.text("jst_myplace")]),
    html.nav([], nav_links |> list.map(view_nav_link)),
  ])
}
