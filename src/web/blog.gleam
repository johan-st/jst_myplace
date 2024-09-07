import birl
import filepath
import gleam/dict
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import jot
import lustre/element.{type Element}
import simplifile.{type FileError} as file
import wisp.{type Body}

pub type Post {
  Post(frontmatter: Frontmatter, document: jot.Document)
}

pub type Frontmatter {
  Frontmatter(
    title: String,
    slug: String,
    publish_date: Option(birl.Time),
    tags: List(String),
  )
}

pub fn posts_from_dir(dir: String) -> List(Post) {
  case file.read_directory(dir) {
    Ok(files_and_folders) ->
      files_and_folders
      |> list.map(filepath.join(dir, _))
      |> list.filter(string.ends_with(_, ".md"))
      |> list.filter_map(file.read)
      |> list.map(post_from_string)
      |> result.values
    Error(_) -> []
  }
}

fn post_from_string(file_content content: String) -> Result(Post, Nil) {
  let split_string =
    result.or(
      string.split_once(content, "\n---\n"),
      string.split_once(content, "\r\n---\r\n"),
    )

  case split_string {
    Ok(parts) -> {
      let #(frontmatter_string, content_string) = parts
      let frontmatter = parse_frontmatter(frontmatter_string)
      let doc = jot.parse(content_string)
      case frontmatter {
        Ok(fm) -> Ok(Post(frontmatter: fm, document: doc))
        _ -> Error(Nil)
      }
    }
    Error(Nil) -> Error(Nil)
  }
}

pub fn parse_frontmatter(
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

  let res_title = dict.get(front_dict, "title")

  let res_slug = dict.get(front_dict, "slug")

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
    Error(Nil), _, _, _ -> Error("missing title")
    _, Error(Nil), _, _ -> Error("missinng slug")
  }
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
