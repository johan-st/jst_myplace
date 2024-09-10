import gleam/dynamic.{bool, field, string}
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None}
import gleam/result

import gleam/string
import gleeunit
import gleeunit/should
import web/blog

pub fn main() {
  gleeunit.main()
}

pub type FrontmatterIntermediate {
  FrontmatterIntermediate(
    draft: Bool,
    title: String,
    publish_date: String,
    slug: String,
    summary: String,
    tags: String,
    uid: String,
  )
}

pub type Frontmatter {
  Frontmatter(
    draft: Bool,
    title: String,
    publish_date: String,
    slug: String,
    summary: String,
    tags: List(String),
    uid: String,
  )
}

pub fn blog_parse_test() {
  let json =
    "{
    \"draft\": true,
    \"title\": \"test\",
    \"date\": \"2024-08-18T00:00:00.000Z\",
    \"slug\": \"tst\",
    \"summary\": \"just a test document\",
    \"tags\": \"first,my_post,test\",
    \"uid\": \"fey5oc7ptsk\"
    }"

  let decoder =
    dynamic.decode7(
      FrontmatterIntermediate,
      field("draft", of: bool),
      field("title", of: string),
      field("date", of: string),
      field("slug", of: string),
      field("summary", of: string),
      field("tags", of: string),
      field("uid", of: string),
    )
  let split_tags = fn(tags: String) -> List(String) {
    tags
    |> string.split(",")
    |> list.map(string.trim)
  }
  json.decode(from: json, using: decoder)
  |> result.map(fn(fm) {
    Frontmatter(
      draft: fm.draft,
      title: fm.title,
      publish_date: fm.publish_date,
      slug: fm.slug,
      summary: fm.summary,
      tags: fm.tags |> split_tags,
      uid: fm.uid,
    )
  })
  |> io.debug
}
