import gleam/dict.{type Dict}
import gleam/option.{type Option}

type Attributes {
  Attributes(
    attributes: Dict(String, String),
    auto_attributes: Dict(String, String),
    pos: Option(Pos),
  )
}

type SourceLoc {
  SourceLoc(line: Int, col: Int, offset: Int)
}

type Pos {
  Pos(start: SourceLoc, end: SourceLoc)
}

type Block {
  Para(attr: Attributes, children: List(Inline))
  Heading(attr: Attributes, level: Int, children: List(Inline))
  ThematicBreak(attr: Attributes)
  Section(attr: Attributes, children: List(Block))
  Div(attr: Attributes, children: List(Block))
  CodeBlock(attr: Attributes, lang: Option(String), text: String)
  RawBlock(attr: Attributes, format: String, text: String)
  // what is format?
  BlockQuote(attr: Attributes, children: List(Block))
  OrderedList(
    attr: Attributes,
    tight: Bool,
    style: OrderedListStyle,
    start: Option(Int),
    children: List(ListItem),
  )
  BulletList(
    attr: Attributes,
    tight: Bool,
    style: BulletListStyle,
    children: List(ListItem),
  )
  TaskList(attr: Attributes, tight: Bool, children: List(TaskListItem))
  DefinitionList(attr: Attributes, children: List(DefinitionListItem))
  Table(attr: Attributes, caption: Caption, children: List(Row))
}

// Translations to fit TypeScript reference implementation 
type ListItem =
  AstNode

type TaskListItem =
  AstNode

type Definition =
  AstNode

type DefinitionListItem =
  AstNode

type Row =
  AstNode

type Cell =
  AstNode

type Caption =
  AstNode

type Reference =
  AstNode

type Footnote =
  AstNode

type Term =
  AstNode

type Inline {
  Str(attr: Attributes, text: String)
  SoftBreak(attr: Attributes)
  HardBreak(attr: Attributes)
  NonBreakingSpace(attr: Attributes)
  Symb(attr: Attributes, alias: String)
  Verbatim(attr: Attributes, text: String)
  RawInline(attr: Attributes, format: String, text: String)
  // what is format?
  InlineMath(attr: Attributes, text: String)
  DisplayMath(attr: Attributes, text: String)
  Url(attr: Attributes, text: String)
  Email(attr: Attributes, text: String)
  FootnoteReference(attr: Attributes, text: String)
  SmartPunctuation(
    attr: Attributes,
    smart_punct_type: SmartPunctuationType,
    text: String,
  )
  Emph(attr: Attributes, children: List(Inline))
  Strong(attr: Attributes, children: List(Inline))
  Link(
    attr: Attributes,
    dest: Option(String),
    ref: Option(String),
    children: List(Inline),
  )
  // TODO: do we ever have both or none of dest and ref?
  Image(
    attr: Attributes,
    dest: Option(String),
    ref: Option(String),
    children: List(Inline),
  )
  // TODO: do we ever have both or none of dest and ref?
  Span(attr: Attributes, children: List(Inline))
  Mark(attr: Attributes, children: List(Inline))
  Superscript(attr: Attributes, children: List(Inline))
  Subscript(attr: Attributes, children: List(Inline))
  Insert(attr: Attributes, children: List(Inline))
  Delete(attr: Attributes, children: List(Inline))
  DoubleQuoted(attr: Attributes, children: List(Inline))
  SingleQuoted(attr: Attributes, children: List(Inline))
}

type BulletListStyle {
  Dash
  Plus
  Star
}

type OrderedListStyle {
  // 1.
  NumDot
  // 1)
  NumParen
  // (1)
  ParenNumParen
  // a.
  LowerAlphaDot
  // a)
  LowerAlphaParen
  // (a)
  ParenLowerAlphaParen
  // A.
  UpperAlphaDot
  // A)
  UpperAlphaParen
  // (A)
  ParenUpperAlphaParen
  // i.
  LowerRomanDot
  // i) 
  LowerRomanParen
  // (i)
  ParenLowerRomanParen
  // I.
  UpperRomanDot
  // I)
  UpperRomanParen
  // (I)
  ParenUpperRomanParen
}

type CheckboxStatus =
  Bool

type SmartPunctuationType {
  LeftSingleQuote
  RightSingleQuote
  LeftDoubleQuote
  RightDoubleQuote
  Ellipses
  EmDash
  EnDash
}

type Alignment {
  Default
  Left
  Right
  Center
}

type AstNode {
  Doc(
    attr: Attributes,
    refs: Dict(String, Reference),
    auto_refs: Dict(String, Reference),
    footnotes: Dict(String, Footnote),
    children: List(Block),
  )
  Block
  Inline
  ListItem(attr: Attributes, children: List(Block))
  TaskListItem(
    attr: Attributes,
    checkbox: CheckboxStatus,
    children: List(Block),
  )
  DefinitionListItem(attr: Attributes, term: Term, definition: Definition)
  Term(attr: Attributes, children: List(Inline))
  Definition(attr: Attributes, children: List(Block))
  Row(attr: Attributes, head: Bool, children: List(Cell))
  Cell(attr: Attributes, head: Bool, align: Alignment, children: List(Inline))
  Caption(attr: Attributes, children: List(Inline))
  Footnote(attr: Attributes, label: String, children: List(Block))
  Reference(attr: Attributes, label: String, destination: String)
}
// TODO: is this visitor pattern?

// type Visitor<C, R> = {
//   doc?: (node: Doc, context: C) => R;
//   para?: (node: Para, context: C) => R;
//   heading?: (node: Heading, context: C) => R;
//   thematic_break?: (node: ThematicBreak, context: C) => R;
//   section?: (node: Section, context: C) => R;
//   div?: (node: Div, context: C) => R;
//   code_block?: (node: CodeBlock, context: C) => R;
//   raw_block?: (node: RawBlock, context: C) => R;
//   block_quote?: (node: BlockQuote, context: C) => R;
//   ordered_list?: (node: OrderedList, context: C) => R;
//   bullet_list?: (node: BulletList, context: C) => R;
//   task_list?: (node: TaskList, context: C) => R;
//   definition_list?: (node: DefinitionList, context: C) => R;
//   table?: (node: Table, context: C) => R;
//   str?: (node: Str, context: C) => R;
//   soft_break?: (node: SoftBreak, context: C) => R;
//   hard_break?: (node: HardBreak, context: C) => R;
//   non_breaking_space?: (node: NonBreakingSpace, context: C) => R;
//   symb?: (node: Symb, context: C) => R;
//   verbatim?: (node: Verbatim, context: C) => R;
//   raw_inline?: (node: RawInline, context: C) => R;
//   inline_math?: (node: InlineMath, context: C) => R;
//   display_math?: (node: DisplayMath, context: C) => R;
//   url?: (node: Url, context: C) => R;
//   email?: (node: Email, context: C) => R;
//   footnote_reference?: (node: FootnoteReference, context: C) => R;
//   smart_punctuation?: (node: SmartPunctuation, context: C) => R;
//   emph?: (node: Emph, context: C) => R;
//   strong?: (node: Strong, context: C) => R;
//   link?: (node: Link, context: C) => R;
//   image?: (node: Image, context: C) => R;
//   span?: (node: Span, context: C) => R;
//   mark?: (node: Mark, context: C) => R;
//   superscript?: (node: Superscript, context: C) => R;
//   subscript?: (node: Subscript, context: C) => R;
//   insert?: (node: Insert, context: C) => R;
//   delete?: (node: Delete, context: C) => R;
//   double_quoted?: (node: DoubleQuoted, context: C) => R;
//   single_quoted?: (node: SingleQuoted, context: C) => R;
//   list_item?: (node: ListItem, context: C) => R;
//   task_list_item?: (node: TaskListItem, context: C) => R;
//   definition_list_item?: (node: DefinitionListItem, context: C) => R;
//   term?: (node: Term, context: C) => R;
//   definition?: (node: Definition, context: C) => R;
//   row?: (node: Row, context: C) => R;
//   cell?: (node: Cell, context: C) => R;
//   caption?: (node: Caption, context: C) => R;
//   footnote?: (node: Footnote, context: C) => R;
//   reference?: (node: Reference, context: C) => R;
// };

// /* Type predicates */

// const blockTags : Record<string, boolean> = {
//   para: true,
//   heading: true,
//   block_quote: true,
//   thematic_break: true,
//   section: true,
//   div: true,
//   code_block: true,
//   raw_block: true,
//   bullet_list: true,
//   ordered_list: true,
//   task_list: true,
//   definition_list: true,
//   table: true,
//   reference: true,
//   footnote: true
// };

// function isBlock(node : AstNode) : node is Block {
//   return blockTags[node.tag] || false;
// }

// const inlineTags : Record<string, boolean> = {
//   str: true,
//   soft_break: true,
//   hard_break: true,
//   non_breaking_space: true,
//   symb: true,
//   verbatim: true,
//   raw_inline: true,
//   inline_math: true,
//   display_math: true,
//   url: true,
//   email: true,
//   footnote_reference: true,
//   smart_punctuation: true,
//   emph: true,
//   strong: true,
//   link: true,
//   image: true,
//   span: true,
//   mark: true,
//   superscript: true,
//   subscript: true,
//   insert: true,
//   delete: true,
//   double_quoted: true,
//   single_quoted: true,
// };

// function isInline(node : AstNode) : node is Inline {
//   return inlineTags[node.tag] || false;
// }

// function isRow(node : Row | Caption) : node is Row {
//   return ("head" in node);
// }

// function isCaption(node : Row | Caption) : node is Caption {
//   return (!("head" in node));
// }

// export type {
//   Attributes,
//   SourceLoc,
//   Pos,
//   HasAttributes,
//   HasChildren,
//   HasText,
//   Block,
//   Para,
//   Heading,
//   ThematicBreak,
//   Section,
//   Div,
//   CodeBlock,
//   RawBlock,
//   BlockQuote,
//   BulletList,
//   BulletListStyle,
//   OrderedList,
//   OrderedListStyle,
//   ListItem,
//   TaskList,
//   TaskListItem,
//   CheckboxStatus,
//   DefinitionList,
//   DefinitionListItem,
//   Term,
//   Definition,
//   Table,
//   Caption,
//   Row,
//   Cell,
//   Alignment,
//   Inline,
//   Str,
//   SoftBreak,
//   HardBreak,
//   NonBreakingSpace,
//   Symb,
//   Verbatim,
//   RawInline,
//   InlineMath,
//   DisplayMath,
//   Url,
//   Email,
//   FootnoteReference,
//   SmartPunctuationType,
//   SmartPunctuation,
//   Emph,
//   Strong,
//   Link,
//   Image,
//   Span,
//   Mark,
//   Superscript,
//   Subscript,
//   Insert,
//   Delete,
//   DoubleQuoted,
//   SingleQuoted,
//   AstNode,
//   Doc,
//   Reference,
//   Footnote,
//   Visitor,
// }
// export {
//   isInline,
//   isBlock,
//   isRow,
//   isCaption
// }
