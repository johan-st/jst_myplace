import gleam/dict.{type Dict}
import gleam/option.{type Option}
import parsing/jst_down as ast

type Container {
  Container(
    children: List(ContainerChild),
    attr: ast.Attributes,
    data: Dict(String, Any),
  )
}

type Any {
  Placeholder
}

// Can types be overloaded
type ContainerChild {
  ChildInline(ast.Inline)
  ChildBlock(ast.Block)
  ChildAstNode(ast.AstNode)
}
