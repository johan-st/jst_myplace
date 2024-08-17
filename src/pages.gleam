import gleam/bytes_builder
import gleam/http/response.{type Response}
import lustre/element.{type Element}
import lustre/element/html.{html}
import mist.{type ResponseData}

fn html_base(body: List(Element(a)), title: String) -> Element(a) {
  html([], [html.head([], [html.title([], title)]), html.body([], body)])
}

pub fn greet(name: String) -> Response(ResponseData) {
  let res = response.new(200)
  let html =
    html([], [
      html.body([], [html.h1([], [html.text("Hey there, " <> name <> "!")])]),
    ])

  response.set_body(
    res,
    [html]
      |> html_base("Greetings")
      |> element.to_document_string
      |> bytes_builder.from_string
      |> mist.Bytes,
  )
}

pub fn from_string(s: String, code: Int) -> Response(ResponseData) {
  let res = response.new(code)
  response.set_body(
    res,
    s
      |> bytes_builder.from_string
      |> mist.Bytes,
  )
}
