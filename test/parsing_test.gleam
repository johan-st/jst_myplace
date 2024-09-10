import chomp
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/string
import gleeunit
import parsing/djot
import parsing/jst_down as jd
import utils/support

pub fn main() {
  gleeunit.main()
}

pub fn test_wip() {

}

// pub fn djot_test() {
//   let tests = support.load_djot_example_test_cases()
//   use testcase <- list.each(tests)
//   let result = djot.to_html(testcase.input)
//   case result == testcase.html {
//     True -> io.print_error(".")
//     False -> {
//       io.print_error("F")
//       io.print_error("\n\nTest failed: " <> testcase.file)
//       io.print_error("\n\nInput:\n" <> testcase.input)
//       io.print_error("\nExpected:\n" <> string.inspect(testcase.html))
//       io.print_error("\nActual:\n" <> string.inspect(result))
//       io.print_error("\n")
//       panic as "parsing test failed"
//     }
//   }
// }

// pub fn jd_test() {
//   let tests = support.load_jd_example_test_cases()
//   use testcase <- list.each(tests)
//   let result = jd.to_html(testcase.input)
//   case result == testcase.html {
//     True -> io.print_error(".")
//     False -> {
//       io.print_error("F")
//       io.print_error("\n\nTest failed: " <> testcase.file)
//       io.print_error("\n\nInput:\n" <> testcase.input)
//       io.print_error("\nExpected:\n" <> string.inspect(testcase.html))
//       io.print_error("\nActual:\n" <> string.inspect(result))
//       io.print_error("\n")
//       panic as "parsing test failed"
//     }
//   }
// }
