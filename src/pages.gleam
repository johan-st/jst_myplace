import gleam/bytes_builder
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/list
import gleam/string
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

pub fn debug(req: Request(a)) -> Response(ResponseData) {
  io.debug(req)
  let res = response.new(200)
  let path = request.path_segments(req) |> string.join("/")
  let query = case request.get_query(req) {
    Ok(query_list) ->
      query_list
      |> list.map(fn(query) {
        let #(name, value) = query
        name <> ": " <> value
      })
      |> string.join("\n")
    Error(_) -> "<none>"
  }
  let cookies =
    request.get_cookies(req)
    |> list.map(fn(cookie) {
      let #(name, value) = cookie
      name <> ": " <> value
    })
  let headers = "<not implemented>"
  let method = "<not implemented>"

  let html =
    html([], [
      html.body([], [
        html.h1([], [html.text("Request Debug")]),
        html.section([], [
          html.h2([], [html.text("Method")]),
          html.pre([], [html.text(method)]),
        ]),
        html.section([], [
          html.h2([], [html.text("Path")]),
          html.pre([], [html.text(path)]),
        ]),
        html.section([], [
          html.h2([], [html.text("Query")]),
          html.pre([], [html.text(query)]),
        ]),
        html.section([], [
          html.h2([], [html.text("Cookies")]),
          html.pre([], [html.text(cookies |> string.join("\n"))]),
        ]),
        html.section([], [
          html.h2([], [html.text("Headers")]),
          html.pre([], [html.text(headers)]),
        ]),
      ]),
    ])

  response.set_body(
    res,
    [html]
      |> html_base("Request Debug")
      |> element.to_document_string
      |> bytes_builder.from_string
      |> mist.Bytes,
  )
}
