import birl
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute.{type Attribute, attribute, class, href}
import lustre/element.{type Element}
import lustre/element/html.{html}
import web/blog
import wisp.{type Body}

pub fn view_index(blogs: List(blog.Post)) -> Element(Body) {
  let _ = io.debug("Rendering blog index")
  let _ = io.debug(blogs)
  [
    html.h1([], [html.text("Blog Index!")]),
    html.p([], [html.text("This is a simple web app written in Gleam.")]),
    html.ul([], [
      blogs
      |> list.map(view_post_listitem)
      |> element.fragment,
    ]),
  ]
  |> element.fragment
}

fn view_post_listitem(post: blog.Post) -> Element(Body) {
  let el_date = case post.frontmatter.publish_date {
    Some(date) ->
      html.div([class("date")], [birl.to_http_with_offset(date) |> html.text])
    None -> html.div([class("date none")], [" - " |> html.text])
  }

  html.li([], [
    html.a([href("/blog/" <> post.frontmatter.slug)], [
      html.h2([], [html.text(post.frontmatter.title)]),
      el_date,
    ]),
  ])
}

pub fn view_post(post: blog.Post) -> Element(Body) {
  [
    html.h1([], [html.text(post.frontmatter.title)]),
    element_from_string(post.html),
  ]
  |> element.fragment
}

fn element_from_string(content: String) -> Element(Body) {
  element.text(content)
}
