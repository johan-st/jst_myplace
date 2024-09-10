import simplifile
import filepath
import gleam/list
import gleam/string

pub type Example {
  Example(file: String, input: String, html: String)
}

const djot_dir = "test/djot_parsing_test/cases"
const jd_dir = "test/jd_parsing_test/cases"

pub fn load_djot_example_test_cases() -> List(Example) {
  let assert Ok(tests) = simplifile.read_directory(djot_dir)
  tests
  |> list.map(filepath.join(djot_dir, _))
  |> list.flat_map(load_and_parse_file)
}

pub fn load_jd_example_test_cases() -> List(Example) {
  let assert Ok(tests) = simplifile.read_directory(jd_dir)
  tests
  |> list.map(filepath.join(jd_dir, _))
  |> list.flat_map(load_and_parse_file)
}

fn load_and_parse_file(path: String) -> List(Example) {
  let assert Ok(content) = simplifile.read(path)
  content
  |> string.split("\n")
  |> parse(path, [])
}

fn parse(
  lines: List(String),
  path: String,
  examples: List(Example),
) -> List(Example) {
  let lines = pop_empty(lines)
  case lines {
    [] -> list.reverse(examples)
    [delim, ..lines] -> {
      case string.starts_with(delim, "`") {
        True -> {
          let #(example, lines) = parse_one(lines, delim, path)
          parse(lines, path, [example, ..examples])
        }
        False -> parse(lines, path, examples)
      }
    }
  }
}

fn parse_one(
  lines: List(String),
  delim: String,
  path: String,
) -> #(Example, List(String)) {
  let #(djot, lines) = collect_until(lines, ".", "")
  let #(html, lines) = collect_until(lines, delim, "")
  let example = Example(path, djot, html)
  #(example, lines)
}

fn collect_until(
  lines: List(String),
  end: String,
  acc: String,
) -> #(String, List(String)) {
  case lines {
    [] -> #(acc, [])
    [line, ..lines] if line == end -> #(acc, lines)
    [line, ..lines] -> collect_until(lines, end, acc <> line <> "\n")
  }
}

fn pop_empty(lines: List(String)) -> List(String) {
  case lines {
    ["", ..lines] -> pop_empty(lines)
    _ -> lines
  }
}
