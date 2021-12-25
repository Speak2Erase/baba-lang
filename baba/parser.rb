class BaBaParser
  require_relative "parser/lexer"
  require_relative "parser/error"
  require_relative "parser/classes"
  require_relative "parser/ast"

  STATEMENTS = [
    :$event,
    :$page,
    :$movement,
    :$commands,
    :$graphic,
    :$condition,
    :$choices,
    :$textbox,
  ]

  TOKENS = Lexer::TOKENS

  def parse(code)
    lexer = Lexer.new(code)
    AST.parse(lexer)
  end
end

require "ap"
ap BaBaParser.new.parse(File.read("../example_event.baba")), { raw: true }
