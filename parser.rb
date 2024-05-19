# frozen_string_literal: true

require_relative 'expr'
require_relative 'lox'

# Lox parser class
class Parser
  class ParseError < RuntimeError
  end

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    expression
  rescue ParseError
    nil
  end

  def expression
    equality
  end

  def equality
    expr = comparison
    while match(:BANG_EQUAL, :EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = term
    while match(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL)
      operator = previous
      right = term
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def term
    expr = factor
    while match(:MINUS, :PLUS)
      operator = previous
      right = factor
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def factor
    expr = unary
    while match(:SLASH, :STAR)
      operator = previous
      right = unary
      expr = Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match(:BANG, :MINUS)
      operator = previous
      right = unary
      return Unary.new(operator, right)
    end

    primary
  end

  def primary
    return Literal.new(false) if match(:FALSE)
    return Literal.new(true) if match(:TRUE)
    return Literal.new(nil) if match(:NIL)
    return Literal.new(previous.literal) if match(:NUMBER, :STRING)

    if match(:LEFT_PAREN)
      expr = expression
      consume(:RIGHT_PAREN, "Expect ')' after expression.")
      return Grouping.new(expr)
    end

    raise error(peek, 'Expect expression.')
  end

  def match(*types)
    types.each do |type|
      if check type
        advance
        return true
      end
    end

    false
  end

  def consume(type, message)
    return advance if check type

    raise error(peek, message)
  end

  def check(type)
    at_end? ? false : peek.type == type
  end

  def advance
    (@current += 1) unless at_end?
    previous
  end

  def at_end?
    peek.type == :EOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def error(token, message)
    parse_error(token, message)
    ParseError.new
  end

  def synchronize
    advance
    until at_end?
      return if previous.type == :SEMICOLON

      case peek.type
      when :CLASS,
      :FUN,
      :VAR,
      :FOR,
      :IF,
      :WHILE,
      :PRINT,
      :RETURN
        return
      end

      advance
    end
  end
end
