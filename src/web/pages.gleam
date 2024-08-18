import gleam/http.{Get}

import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html.{html}
import web/pages/api_docs
import web/pages/home
import wisp.{type Request, type Response}

fn html_base(body: List(Element(a)), title: String) -> Element(a) {
  html([], [
    html.head([], [
      html.title([], title),
      // TODO: consider injecting base styles and scripts into the document to avoid requests
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/base.css"),
      ]),
      html.script(
        [attribute.attribute("load", "defer"), attribute.src("/static/main.js")],
        "",
      ),
    ]),
    html.body([], body),
  ])
}

// HOME/INDEX
pub fn home(req: Request) -> Response {
  use <- wisp.require_method(req, Get)

  let html =
    [home.view()]
    |> html_base("Home | jst_myplace")
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(html)
}

// API DOCS
pub fn api_docs(req: Request) -> Response {
  use <- wisp.require_method(req, Get)

  let html =
    [api_docs.view()]
    |> html_base("API Docs | jst_myplace")
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(html)
}
