import context.{type ServerContext}
import lustre/element
import web/html/pages/api_docs
import web/html/pages/home
import web/html/partials/html_base
import wisp.{type Response}

pub fn home(ctx: ServerContext) -> Response {
  let html =
    html_base.document(ctx, "Home", home.view())
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(html)
}

pub fn api_docs(ctx) -> Response {
  let html =
    html_base.document(ctx, "API Docs", api_docs.view())
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(html)
}
