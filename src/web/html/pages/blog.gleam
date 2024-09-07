import birl
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import jot
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
    element_from_doc(post.document),
  ]
  |> element.fragment
}

pub fn element_from_doc(document doc: jot.Document) -> Element(Body) {
  let content = doc.content
  // let _references = doc.references
  content
  |> list.map(element_from_container)
  |> element.fragment
}

fn element_from_container(container cont: jot.Container) -> Element(Body) {
  case cont {
    jot.Paragraph(attrs, cont) ->
      html.p(attrs_from_dict(attrs), list.map(cont, element_from_inline))
    jot.Heading(attrs, lvl, cont) ->
      case lvl {
        1 ->
          html.h1(attrs_from_dict(attrs), list.map(cont, element_from_inline))
        2 ->
          html.h2(attrs_from_dict(attrs), list.map(cont, element_from_inline))
        3 ->
          html.h3(attrs_from_dict(attrs), list.map(cont, element_from_inline))
        4 ->
          html.h4(attrs_from_dict(attrs), list.map(cont, element_from_inline))
        5 ->
          html.h5(attrs_from_dict(attrs), list.map(cont, element_from_inline))
        _ ->
          html.h6(attrs_from_dict(attrs), list.map(cont, element_from_inline))
      }
    jot.Codeblock(attrs, lang, cont) ->
      element_from_codeblock(attrs, lang, cont)
  }
}

fn attrs_from_dict(attrs: Dict(String, String)) -> List(Attribute(msg)) {
  dict.to_list(attrs)
  |> list.map(fn(attr) {
    let #(key, val) = attr
    attribute(key, val)
  })
}

fn element_from_inline(inline: jot.Inline) -> Element(msg) {
  case inline {
    jot.Linebreak -> html.br([])
    jot.Text(str) -> html.text(str)
    jot.Link(content, destination) ->
      case destination {
        jot.Reference(ref) ->
          html.a([attribute.href(ref)], list.map(content, element_from_inline))
        jot.Url(str) ->
          html.a([attribute.href(str)], list.map(content, element_from_inline))
      }
    jot.Image(content, destination) ->
      case destination {
        jot.Reference(ref) ->
          html.img([
            attribute.src(ref),
            attribute.alt(string_from_inlines(content)),
          ])
        jot.Url(str) ->
          html.img([
            attribute.src(str),
            attribute.alt(string_from_inlines(content)),
          ])
      }
    jot.Emphasis(content) -> html.em([], list.map(content, element_from_inline))
    jot.Strong(content) ->
      html.strong([], list.map(content, element_from_inline))
    jot.Code(content) -> html.code([], [html.text(content)])
  }
}

fn string_from_inlines(inlines: List(jot.Inline)) -> String {
  let assert [jot.Text(str)] = inlines
  str
}

fn element_from_codeblock(
  attrs: Dict(String, String),
  lang: Option(String),
  content: String,
) -> Element(Body) {
  let attr_lang = case lang {
    Some(str) -> [attribute.class("language-" <> str)]
    None -> []
  }
  html.pre(attrs_from_dict(attrs), [html.code(attr_lang, [html.text(content)])])
}
