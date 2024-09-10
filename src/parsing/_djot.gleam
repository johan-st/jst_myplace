//// Djot is a simple markup language for writing documents.
//// Syntax is described [here](https://htmlpreview.github.io/?https://github.com/jgm/djot/blob/master/doc/syntax.html)
//// It is designed to be parsed in linear time without backtracking.
//// 
//// Like Markdown, Djot can not fail to parse. If the input is not well-formed Djot, the parser will still produce a result.

import chomp/lexer.{type Matcher, Token}
import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/set
import gleam/string
import lustre/element/html

// PUBLIC API
pub fn to_html(input: String) -> String {
  input
  |> parse_document
  |> doc_to_html
}

/// Top level definition
type Document {
  Document(List(Block))
}

type Block {
  Paragraph(List(Inline))
  // Headin(List(Inline))
  // BlockQ(List(Inline))
  // ListIt(List(Inline))
  // List
  // CodeBl(List(Inline))
  // THemat(List(Inline))
  // RawBlo(List(Inline))
  // Div
  // PipeTa(List(Inline))
  // Refere(List(Inline))
  // Footno(List(Inline))
  // BlockA(List(Inline))
}

type Inline {
  Text(String)
  // Link
  // Image
  // Autolink
  // Verbatim
  // Emphasis
  // Strong
  // Highlighted
  // Superscript
  // Subscript
  // Insert
  // Delete
  // SmartPunctuation
  // Math
  // FootnoteReference
  // LineBreak
  // Comment
  // Symbols
  // RawInline
  // Span
  // InlineAttributes
}

// PARSING 

type ParsingContext {
  ParsingContext(
    blocks: List(Block),
    current_block: Option(Block),
    current_inline: Option(Inline),
    current_text: String,
  )
}

fn parse_document(input: String) -> Document {
  let ctx =
    ParsingContext(
      blocks: [],
      current_block: None,
      current_inline: None,
      current_text: "",
    )

  input
  |> string.split("\n")
  |> list.fold(from: ctx, with: parse_line)
  |> ctx_to_document
}

fn parse_line(ctx: ParsingContext, line: String) -> ParsingContext {
  case ctx {
    ParsingContext(_, None, ..) -> parse_block(ctx, line)
    ParsingContext(_, Some(_), ..) -> parse_inline(ctx, line)
  }
}

// blocks
fn parse_block(ctx: ParsingContext, line: String) -> ParsingContext {
  case line {
    _ -> parse_paragraph(ctx, line)
  }
}

fn parse_paragraph(ctx: ParsingContext, line: String) -> ParsingContext {
  case ctx {
    ParsingContext(blocks: blocks, ..) -> {
      let new_block = Paragraph([Text(line)])
      ParsingContext(..ctx, blocks: [new_block, ..blocks])
    }
  }
}

// inline
fn parse_inline(ctx: ParsingContext, line: String) -> ParsingContext {
  case line {
    _ -> parse_text(ctx, line)
  }
}

fn parse_text(ctx: ParsingContext, line: String) -> ParsingContext {
  case ctx {
    ParsingContext(current_text: text, ..) -> {
      let new_text = text <> " " <> line
      ParsingContext(..ctx, current_text: new_text)
    }
  }
}

// TRANSFORMING

fn ctx_to_document(ctx: ParsingContext) -> Document {
  case ctx {
    ParsingContext(blocks, ..) -> Document(blocks)
  }
}

fn doc_to_html(doc: Document) -> String {
  case doc {
    Document(blocks) ->
      blocks
      |> list.map(block_to_html)
      |> string.join("\n")
  }
}

fn block_to_html(block: Block) -> String {
  case block {
    Paragraph(inlines) ->
      inlines
      |> list.map(inline_to_html)
      |> string.join(" ")
  }
}

fn inline_to_html(inline: Inline) -> String {
  case inline {
    Text(text) -> text
  }
}
