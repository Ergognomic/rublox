# frozen_string_literal: true

require_relative 'lox'
require_relative 'expr'
require_relative 'stmt'

# Lox parser class
class Parser
  class ParseError < RuntimeError
  end

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    statements = []
    statements << declaration until at_end?

    statements
  rescue ParseError
    nil
  end

  def expression
    assignment
  end

  def declaration
    return function 'function' if match :FUN
    return var_declaration if match :VAR

    statement
  rescue ParseError
    synchronize
    nil
  end

  def statement
    return for_statement if match :FOR
    return if_statement if match :IF
    return print_statement if match :PRINT
    return while_statement if match :WHILE
    return Block.new(block) if match :LEFT_BRACE

    expression_statement
  end

  def for_statement
    consume(:LEFT_PAREN, "Expect '(' after 'for'.")
    initializer = if match :SEMICOLON
                    nil
                  elsif match :VAR
                    var_declaration
                  else
                    expression_statement
                  end
    condition = expression unless check :SEMICOLON
    consume(:SEMICOLON, "Expect ';' after loop condition.")
    increment = expression unless check :RIGHT_PAREN
    consume(:RIGHT_PAREN, "Expect ')' after for clause.")
    body = statement
    body = Block.new([body, Expression.new(increment)]) unless increment.nil?
    condition = Literal.new(true) if condition.nil?
    body = While.new(condition, body)
    body = Block.new([initializer, body]) unless initializer.nil?

    body
  end

  def if_statement
    consume(:LEFT_PAREN, "Expect '(' after 'if'.")
    condition = expression
    consume(:RIGHT_PAREN, "Expect ')' after if condition.")
    then_branch = statement
    else_branch = statement if match :ELSE

    If.new(condition, then_branch, else_branch)
  end

  def print_statement
    value = expression
    consume(:SEMICOLON, "Expect ';' after value.")

    Print.new value
  end

  def var_declaration
    name = consume(:IDENTIFIER, 'Expect variable name.')
    initializer = expression if match(:EQUAL)
    consume(:SEMICOLON, "Expect ';' after variable declaration.")

    Var.new(name, initializer)
  end

  def while_statement
    consume(:LEFT_PAREN, "Expect '(' after 'while'.")
    condition = expression
    consume(:RIGHT_PAREN, "Expect ')' after condition.")
    body = statement

    While.new(condition, body)
  end

  def expression_statement
    expr = expression
    consume(:SEMICOLON, "Expect ';' after expression.")

    Expression.new expr
  end

  def function(kind)
    name = consume(:IDENTIFIER, "Expect #{kind} name.")
    consume(:LEFT_PAREN, "Expect '(' after #{kind} name.")
    parameters = []
    unless check :RIGHT_PAREN
      loop do
        error(peek, "Can't have more than 255 parameters.") if parameters.size >= 255
        parameters << consume(:IDENTIFIER, 'Expect parameter name.')
        break unless match :COMMA
      end
    end
    consume(:RIGHT_PAREN, "Expect ')' after parameters.")
    consume(:LEFT_BRACE, "Expect '{' before #{kind} body.")
    body = block

    Function.new(name, parameters, body)
  end

  def block
    statements = []
    statements << declaration while !check(:RIGHT_BRACE) && !at_end?
    consume(:RIGHT_BRACE, "Expect '}' after block.")

    statements
  end

  def assignment
    expr = logical_or
    if match :EQUAL
      equals = previous
      value = assignment
      return Assign.new(expr.name, value) if expr.is_a? Variable

      error(equals, 'Invalid assignment target.')
    end

    expr
  end

  def logical_or
    expr = logical_and
    while match :OR
      operator = previous
      right = logical_and
      expr = Logical.new(expr, operator, right)
    end

    expr
  end

  def logical_and
    expr = equality
    while match :AND
      operator = previous
      right = equality
      expr = Logical.new(expr, operator, right)
    end

    expr
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

    call
  end

  def finish_call(callee)
    arguments = []
    unless check :RIGHT_PAREN
      loop do
        error(peek, "Can't have more than 255 arguments") if arguments.size >= 255
        arguments << expression
        break unless match :COMMA
      end
    end
    paren = consume(:RIGHT_PAREN, "Expect ')' after arguments.")

    Call.new(callee, paren, arguments)
  end

  def call
    expr = primary
    loop do
      break unless match :LEFT_PAREN

      expr = finish_call expr
    end

    expr
  end

  def primary
    return Literal.new(false) if match(:FALSE)
    return Literal.new(true) if match(:TRUE)
    return Literal.new(nil) if match(:NIL)
    return Literal.new(previous.literal) if match(:NUMBER, :STRING)
    return Variable.new(previous) if match(:IDENTIFIER)

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
