import gleam/http.{Get}
import lustre/element.{type Element}
import lustre/element/html.{html}
import wisp.{type Request, type Response}

pub fn home_page(req: Request) -> Response {
  use <- wisp.require_method(req, Get)

  let content = [
    html.h1([], [html.text("Welcome to the home page!")]),
    html.p([], [html.text("This is a simple web app written in Gleam.")]),
  ]

  let html =
    content
    |> html_base("Home | jst_myplace")
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(html)
}

fn html_base(body: List(Element(a)), title: String) -> Element(a) {
  html([], [html.head([], [html.title([], title)]), html.body([], body)])
}
