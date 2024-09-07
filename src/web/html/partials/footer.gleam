import context
import gleam/list
import lustre/element.{type Element}
import lustre/element/html.{html}
import web/html/partials/utils.{External, Internal, view_nav_link}
import wisp

pub fn view(ctx) -> Element(wisp.Body) {
  let nav_links = [
    Internal("/", "Home"),
    Internal("/blog", "Blog"),
    Internal("/api", "API Docs"),
  ]
  html.footer([], [
    html.section([], nav_links |> list.map(view_nav_link)),
    html.section([], [
      html.p([], [
        html.text("uptime: "),
        utils.view_duration(context.uptime(ctx)),
      ]),
      html.p([], [html.text("region: "), html.text(context.region_code(ctx))]),
    ]),
    html.section([], [
      html.p([], [
        html.text("Built with ❤️ in "),
        view_nav_link(External("https://gleam.run/", "Gleam")),
        html.text("!"),
      ]),
      html.p([], [
        html.text("Hosted on the excellent "),
        view_nav_link(External("https://fly.io/", "Fly.io")),
        html.text("!"),
      ]),
    ]),
  ])
}
