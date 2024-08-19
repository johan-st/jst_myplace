import context.{type ServerContext}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html.{html}
import web/html/partials/footer
import web/html/partials/header
import wisp

pub fn document(
  ctx: ServerContext,
  doc_title: String,
  main_content: Element(wisp.Body),
) -> Element(wisp.Body) {
  html([], [
    html.head([], [
      html.title([], doc_title),
      html.link([
        attribute.rel("icon"),
        attribute.type_("image/ico"),
        attribute.href("/static/favicon.ico"),
      ]),
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
    html.body([], [header.view(), main_content, footer.view(ctx)]),
  ])
}
