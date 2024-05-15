# frozen_string_literal: true

require_relative 'token'
require_relative 'expr'

# Pseudo-implementation of Visitor
class AstPrinter < Visitor
  def print(expr)
    expr.accept(self)
  end

  def visit_binary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_grouping_expr(expr)
    parenthesize('group', expr.expression)
  end

  def visit_literal_expr(expr)
    expr.value.nil? ? 'nil' : expr.value.to_s
  end

  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  def parenthesize(name, *exprs)
    str = "(#{name}"
    exprs.each do |expr|
      str += ' '
      str += expr.accept(self)
    end
    str += ')'
  end
end

# Tests ast_printer.rb
#  Should print (* (- 123) (group 45.67))
if __FILE__ == $PROGRAM_NAME
  # Redirect stdout to a catchable stream
  require 'stringio'
  nonstdout = StringIO.new
  $stdout = nonstdout

  expression = Binary.new(
    Unary.new(
      Token.new(:MINUS, '-', nil, 1),
      Literal.new(123)
    ),
    Token.new(:STAR, '*', nil, 1),
    Grouping.new(
      Literal.new(45.67)
    )
  )

  print AstPrinter.new.print expression
  str = nonstdout.string
  $stdout = STDOUT
  str == '(* (- 123) (group 45.67))' ? puts('pass') : puts("fail - #{str}")
end
