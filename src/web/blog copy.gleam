import birl
import filepath
import gleam/dict
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import jot
import lustre/element.{type Element}
import lustre/element/html
import simplifile.{type FileError} as file
import wisp

pub type Post {
  Post(frontmatter: Frontmatter, html: Element(wisp.Body), file_path: String)
}

pub type Frontmatter {
  Frontmatter(
    title: String,
    slug: String,
    publish_date: Option(birl.Time),
    tags: List(String),
  )
}

pub type BlogError {
  FileError(file_path: String, error: FileError)
  ParseError(file_path: String, error: String)
}

pub fn load_posts_from_path(path: String) -> List(Result(Post, BlogError)) {
  let is_md_file = fn(path: String) -> Bool {
    case file.is_file(path) {
      Ok(res_bool) -> res_bool
      Error(_) -> False
    }
  }

  case file.read_directory(path) {
    Ok(files_and_folders) ->
      files_and_folders
      |> list.map(filepath.join(path, _))
      |> list.filter(is_md_file)
      |> list.filter_map(file.read)
      |> list.map(post_from_string(file_path: path, file_content: _))

    Error(err) -> [Error(FileError(path, err))]
  }
}

fn post_from_string(
  file_path path: String,
  file_content content: String,
) -> Result(Post, BlogError) {
  let split_string =
    result.or(
      string.split_once(content, "\n---\n"),
      string.split_once(content, "\r\n---\r\n"),
    )

  case split_string {
    Ok(parts) -> {
      let #(frontmatter_string, content_string) = parts
      let frontmatter = parse_frontmatter(path, frontmatter_string)
      let jot = jot.parse(content_string)
      case frontmatter, jot {
        Ok(fm), html -> Ok(Post(file_path: path, frontmatter: fm, html: html))
        Ok(_) ->
          ParseError(
            path,
            "failed to parse content of file '"
              <> path
              <> "': "
              <> err
              <> "\nstart of file: "
              <> content |> string.slice(0, 100),
          )
          |> Error
        Error(err), Ok(_) ->
          ParseError(
            path,
            "Failed to parse frontmatter: "
              <> err
              <> "\nstart of file: "
              <> content |> string.slice(0, 100),
          )
          |> Error
        Error(err1), Error(err2) ->
          ParseError(path, err1 <> ". " <> err2) |> Error
      }
    }
    Error(Nil) -> ParseError(path, "No frontmatter found") |> Error
  }
}

pub fn parse_frontmatter(
  file_path file: String,
  frontmatter_string str: String,
) -> Result(Frontmatter, String) {
  let front_dict =
    str
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.filter(string.contains(_, ":"))
    |> list.map(parse_frontmatter_line)
    |> result.values
    |> dict.from_list

  let res_title =
    dict.get(front_dict, "title")
    |> string_required_not_empty

  let res_slug =
    dict.get(front_dict, "slug")
    |> string_required_not_empty

  let publish_date =
    dict.get(front_dict, "publish_date")
    |> result.try(birl.parse)
    |> option.from_result

  let tags =
    dict.get(front_dict, "tags")
    |> result.map(string.split(_, ","))
    |> result.map(list.map(_, string.trim))
    |> fn(res) {
      case res {
        Ok(tags) -> tags
        Error(_) -> []
      }
    }

  case res_title, res_slug, publish_date, tags {
    Ok(title), Ok(slug), date, tags -> Ok(Frontmatter(title, slug, date, tags))
    Error(err), _, _, _ -> Error(file <> ">title" <> ">" <> err)
    _, Error(err), _, _ -> Error(file <> ">slug" <> ">" <> err)
  }
}

fn parse_content(content) -> Element(wisp.Body) {
  content |> jot.parse |> todo
}

// Frontmatter(
//     title: String,
//     slug: String,
//     publish_date: Option(birl.Time),
//     tags: List(String),
//     file_path: String,
//   )
fn parse_frontmatter_line(line: String) -> Result(#(String, String), String) {
  case string.split_once(line, ":") {
    Ok(#(key, value)) -> Ok(#(key |> string.trim, value |> string.trim))
    Error(Nil) -> Error("Failed to split line")
  }
}

fn string_required_not_empty(res: Result(String, Nil)) -> Result(String, String) {
  let trimmed = result.map(res, string.trim)
  case trimmed {
    Ok("") -> Error("can not be empty")
    Error(Nil) -> Error("is required")
    Ok(string) -> Ok(string)
  }
}
