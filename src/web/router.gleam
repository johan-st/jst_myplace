import gleam/io
import context.{type ServerContext}
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import logging as l
import simplifile as file
import web/api
import web/blog
import web/html/pages
import web/middleware
import wisp.{type Request, type Response}

pub fn root(ctx: ServerContext) -> fn(Request) -> Response {
  // Closure for setting up the router.
  let priv = context.priv_directory(ctx)
  // blog
  let blog_posts: List(blog.Post) =
    blog.posts_from_dir(context.priv_directory(ctx) <> "/posts")
    |> io.debug

  let view_blog_index = pages.blog_index(blog_posts)
  let view_blog_post = pages.blog_post(blog_posts)

  let api_router = api.router()

  // The router function.
  fn(req) {
    use req <- middleware.global(req)

    case wisp.path_segments(req) {
      [] -> pages.home(ctx)
      // Static files
      ["static", _] -> serve_static(req, priv <> "/web_assets")
      // Content Pages
      ["api"] -> pages.api_docs(ctx)
      ["blog"] -> view_blog_index(ctx)
      ["blog", slug] -> view_blog_post(ctx, slug)
      // API routes
      ["api", ..path_remaining] -> {
        use req <- middleware.require_auth_header(req)
        api_router(req, path_remaining)
      }
      _ -> page_not_found()
    }
  }
}

fn serve_static(req: Request, from: String) -> Response {
  use <- wisp.serve_static(req, under: "/static", from: from)

  wisp.not_found()
}

// fn log_res_blog(res: Result(blog.Post, blog.BlogError)) {
//   case res {
//     Ok(post) -> {
//       l.log(l.Info, "file: " <> post.file_path <> ": OK")
//       res
//     }
//     Error(blog_err) -> {
//       l.log(l.Info, case blog_err {
//         blog.FileError(p, e) ->
//           "file: " <> p <> ", file error: " <> file.describe_error(e)
//         blog.ParseError(p, e) -> "file: " <> p <> ", parse error: " <> e
//       })
//       res
//     }
//   }
// }

// fn comments(req: Request) -> Response {
//   case req.method {
//     Get -> list_comments()
//     Post -> create_comment(req)
//     _ -> wisp.method_not_allowed([Get, Post])
//   }
// }

// fn list_comments() -> Response {
//   let html = string_builder.from_string("Comments!")
//   wisp.ok()
//   |> wisp.html_body(html)
// }

// fn create_comment(_req: Request) -> Response {
//   let html = string_builder.from_string("Created")
//   wisp.created()
//   |> wisp.html_body(html)
// }

// fn show_comment(req: Request, id: String) -> Response {
//   use <- wisp.require_method(req, Get)

//   let html = string_builder.from_string("Comment with id " <> id)
//   wisp.ok()
//   |> wisp.html_body(html)
// }

fn page_not_found() -> Response {
  wisp.response(404)
  |> wisp.string_body("404 - Not Found")
}
