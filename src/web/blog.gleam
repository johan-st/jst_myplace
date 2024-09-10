import birl
import filepath
import gleam/dict
import gleam/dynamic.{type DecodeError, bool, field, string}
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile as file

pub type Post {
  Post(frontmatter: Frontmatter, html: String)
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
    publish_date: Option(birl.Time),
    slug: String,
    summary: String,
    tags: List(String),
    uid: String,
  )
}

pub fn frontmatter_from_json(
  json: String,
) -> Result(Frontmatter, json.DecodeError) {
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
    let date = case birl.parse(fm.publish_date) {
      Ok(d) -> Some(d)
      Error(_) -> None
    }
    Frontmatter(
      draft: fm.draft,
      title: fm.title,
      publish_date: date,
      slug: fm.slug,
      summary: fm.summary,
      tags: fm.tags |> split_tags,
      uid: fm.uid,
    )
  })
}

pub fn posts_from_dir(dir: String) -> List(Post) {
  case file.read_directory(dir) {
    Ok(files_and_folders) ->
      files_and_folders
      |> io.debug
      |> list.map(filepath.join(dir, _))
      |> list.filter(string.ends_with(_, ".html"))
      |> list.map(post_from_file)
      |> io.debug
      |> result.values
    Error(_) -> []
  }
}

pub type BlogError {
  FileError
  DecodeError
}

pub fn post_from_file(file_path: String) -> Result(Post, Nil) {
  let html_res = file.read(file_path)
  let data_res = file.read(file_path |> string.replace(".html", ".json"))

  case html_res, data_res {
    Ok(html), Ok(data) -> {
      case frontmatter_from_json(data) {
        Ok(fm) -> Ok(Post(frontmatter: fm, html: html))
        Error(err) -> {
          io.debug(err)
          Error(Nil)
        }
      }
    }
    _, _ -> Error(Nil)
  }
}
