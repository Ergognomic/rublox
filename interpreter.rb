# frozen_string_literal: true

require_relative 'expr'
require_relative'stmt'
require_relative 'runtime_error'
require_relative 'lox'

# Lox interpreter class
class Interpreter < Visitor
  def interpret(statements)
    statements.each { |statement| execute statement }
  rescue LoxRuntimeError => e
    runtime_error e
  end

  def stringify(object)
    return 'nil' if object.nil?
    return object.to_s.chomp('.0') if object.is_a? Float

    object.to_s
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_unary_expr(expr)
    right = evaluate expr.right
    case expr.operator.type
    when :MINUS
      check_number_operand(expr.operator, right)
      return -right
    when :BANG
      return !truthy?(right)
    end
    # Unreachable
    nil
  end

  def check_number_operand(operator, operand)
    raise LoxRuntimeError.new(operator, 'Operand must be a number.') unless operand.is_a? Float
  end

  def check_number_operands(operator, left, right)
    raise LoxRuntimeError.new(operator, 'Operands must be numbers.') unless left.is_a?(Float) && right.is_a?(Float)
  end

  def truthy?(object)
    return false if object.nil?
    return object if object.is_a?(TrueClass) || object.is_a?(FalseClass)

    true
  end

  def visit_grouping_expr
    evaluate expr.expression
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def execute(stmt)
    stmt.accept(self)
  end

  def visit_expression_stmt(stmt)
    evaluate stmt.expression
    nil
  end

  def visit_print_stmt(stmt)
    value = evaluate stmt.expression
    puts stringify(value)
  end

  def visit_binary_expr(expr)
    left = evaluate expr.left
    right = evaluate expr.right
    case expr.operator.type
    when :PLUS
      raise LoxRuntimeError.new(expr.operator, 'Operands must be two numbers or two strings.') unless
      (left.is_a?(String) && right.is_a?(String)) || (left.is_a?(Float) && right.is_a?(Float))

      return left + right
    when :MINUS
      check_number_operands(expr.operator, left, right)
      return left - right
    when :SLASH
      check_number_operands(expr.operator, left, right)
      return left / right
    when :STAR
      check_number_operands(expr.operator, left, right)
      return left * right
    when :GREATER
      check_number_operands(expr.operator, left, right)
      return left > right
    when :GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      return left >= right
    when :LESS
      check_number_operands(expr.operator, left, right)
      return left < right
    when :LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      return left <= right
    when :BANG_EQUAL
      return left != right
    when :EQUAL_EQUAL
      return left == right
    end
    # Unreachable
    nil
  end
end
