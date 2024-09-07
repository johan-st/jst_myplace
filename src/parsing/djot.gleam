import chomp/lexer.{type Matcher, Token}
import gleam/regex

import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

pub type Djot {
  Container(List(Djot))
  Inline(List(Djot))
}

pub type DjotToken {
  HashSign
  Newline
  Char(String)
  Space
}

// LEXER
fn tokenize(input) {
  let assert Ok(is_char) = regex.from_string("\\S")
  let match_text =
    lexer.keep(fn(in, next) {
      case regex.check(is_char, in), regex.check(is_char, next) {
        True, False -> Ok(Char(in))
        _, _ -> Error(Nil)
      }
    })
  let match_hash_sign =
    lexer.keep(fn(in, _next) {
      case in {
        "#" -> Ok(HashSign)
        _ -> Error(Nil)
      }
    })
  let match_newline =
    lexer.keep(fn(in, _next) {
      case in {
        "  \n" -> Ok(Newline)
        _ -> Error(Nil)
      }
    })
  let match_spaces = lexer.spaces(Space)

  let lexer =
    lexer.advanced(fn(_mode) -> List(Matcher(DjotToken, mode)) {
      [match_text, match_newline, match_hash_sign, match_spaces]
    })
  lexer.run(input, lexer) |> io.debug
}

// PARSER
fn render(tokens_res) {
  let render_token = fn(token) {
    case token {
      Token(_lexeme, _span, Char(text)) -> text |> tag("p")
      Token(_, _, HashSign) -> todo as "HashSign"
      Token(_, _, Newline) -> "\n"
      Token(_, _, Space) -> ""
    }
  }

  let render_tokens = fn(tokens) {
    list.map(tokens, render_token) |> string.join("")
  }
  render_tokens(tokens_res)
}

fn tag(content, tag) {
  "<" <> tag <> ">" <> content <> "</" <> tag <> ">"
}

pub fn to_html(djot) {
  let assert Ok(tokens) = tokenize(djot) |> io.debug
  let html = render(tokens)
  html
}
