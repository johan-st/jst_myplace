import gleam/io
import gleam/option.{None}
import gleam/result
import gleeunit
import gleeunit/should
import jot
import web/blog

pub fn main() {
  gleeunit.main()
}

// pub fn blog_parse_test() {
//   blog.parse_frontmatter(
//     "test string",
//     "---\ntitle:test_title\nslug:test_slug\ntags:tag1,tag2\n---",
//   )
//   |> should.equal(
//     Ok(
//       blog.Frontmatter(
//         publish_date: None,
//         title: "test_title",
//         slug: "test_slug",
//         tags: ["tag1", "tag2"],
//       ),
//     ),
//   )

//   blog.parse_frontmatter(
//     "test string",
//     "---\ntitle:\nslug:test_slug\ntags:tag1,tag2\n---",
//   )
//   |> result.nil_error
//   |> should.equal(Error(Nil))

//   blog.parse_frontmatter(
//     "test string",
//     "---\n:hello\nslug:test_slug\ntags:tag1,tag2\n---",
//   )
//   |> result.nil_error
//   |> should.equal(Error(Nil))

//   blog.parse_frontmatter(
//     "test string",
//     "---\nslug:test_slug\ntags:tag1,tag2\n---",
//   )
//   |> result.nil_error
//   |> should.equal(Error(Nil))
// }

// pub fn jot_test() {
//   let content =
//     "# Hello, Joe!

// This is a [Djot][djot] document.

// ## second heading

// second heading

// #second heading

// #bobby_is_badass

// [djot]: https://www.djot.net/
// "

//   content |> jot.parse |> io.debug
// }
