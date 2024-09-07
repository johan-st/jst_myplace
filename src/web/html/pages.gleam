import context.{type ServerContext}
import gleam/dict
import gleam/list
import lustre/element
import web/blog
import web/html/pages/api_docs
import web/html/pages/blog as blog_page
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

pub fn blog_index(posts) -> fn(ServerContext) -> Response {
  // closure for init
  let view = blog_page.view_index(posts)

  fn(ctx) {
    let html =
      html_base.document(ctx, "Blog Index", view)
      |> element.to_document_string_builder

    wisp.ok()
    |> wisp.html_body(html)
  }
}

pub fn blog_post(
  blogs: List(blog.Post),
) -> fn(ServerContext, String) -> Response {
  // closure for init
  let posts =
    blogs
    |> list.map(fn(post) { #(post.frontmatter.slug, post) })
    |> dict.from_list

  fn(ctx: ServerContext, slug: String) {
    case dict.get(posts, slug) {
      Ok(post) -> {
        let html =
          html_base.document(ctx, "Blog Index", blog_page.view_post(post))
          |> element.to_document_string_builder

        wisp.ok()
        |> wisp.html_body(html)
      }

      Error(Nil) -> wisp.not_found()
    }
  }
}
