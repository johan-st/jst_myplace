import chomp/lexer
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type Token {
  Number(Int)
  Plus
  //   Minus
  //   Times
  //   Div
  //   LParen
  //   RParen
}

pub fn tokenize(input: String) -> List(lexer.Token(Token)) {
  let lexer =
    lexer.simple([
      lexer.int(Number),
      //   lexer.token("(", LParen),
      //   lexer.token(")", RParen),
      lexer.token("+", Plus),
      // Skip over whitespace, we don't care about it!
      lexer.whitespace(Nil)
        |> lexer.ignore,
    ])
  case lexer.run(input, lexer) {
    Ok(tokens) -> tokens
    Error(error) -> {
      io.print("Error: ")
      io.debug(error)
      io.print("\n")
      []
    }
  }
}
