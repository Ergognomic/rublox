# frozen_string_literal: true

require_relative 'expr'
require_relative 'stmt'
require_relative 'lox'

# Resolves variables
class Resolver < Visitor
  def initialize(interpreter)
    super
    @interpreter = interpreter
    @scopes = []
  end

  def resolve_statements(statements)
    statements.each { |statement| resolve_statement statement }
  end

  def visit_block_stmt(stmt)
    begin_scope
    resolve_statements stmt.statements
    end_scope

    nil
  end

  def visit_expression_stmt(stmt)
    resolve_expression stmt.expression

    nil
  end

  def visit_function_stmt(stmt)
    declare stmt.name
    define stmt.name
    resolve_function stmt

    nil
  end

  def visit_if_stmt(stmt)
    resolve_statement stmt.condition
    resolve_statements stmt.then_branch
    resolve_statements stmt.else_branch unless stmt.else_branch.nil?

    nil
  end

  def visit_print_stmt(stmt)
    resolve_expression stmt.expression

    nil
  end

  def visit_return_stmt(stmt)
    resolve_expression stmt.value unless stmt.value.nil?

    nil
  end

  def visit_var_stmt(stmt)
    declare stmt.name
    resolve_expression stmt.initializer unless stmt.initializer.nil?
    define stmt.name

    nil
  end

  def visit_while_stmt(stmt)
    resolve_statement stmt.condition
    resolve_statements stmt.body

    nil
  end

  def visit_assign_expr(expr)
    resolve_expression expr.value
    resolve_local(expr, expr.name)

    nil
  end

  def visit_variable_expr(expr)
    error(expr.name, "Can't read local variable in its own initializer.") unless
      @scopes.empty? || @scopes.last[expr.name.lexeme] == true
    resolve_local(expr, expr.name)

    nil
  end

  def resolve_statement(stmt)
    raise 'expected Stmt' unless stmt.is_a? Stmt

    stmt.accept self
  end

  def resolve_expression(expr)
    raise 'expected Expr' unless expr.is_a? Expr

    expr.accept self
  end

  def resolve_function(function)
    begin_scope
    function.params.each do |param|
      declare param
      define param
    end
    resolve_statements function.body
    end_scope
  end

  def begin_scope
    @scopes << {}
  end

  def end_scope
    @scopes.pop
  end

  def declare(name)
    return if @scopes.empty?

    @scopes.last[name.lexeme] = false
  end

  def define(name)
    return if @scopes.empty?

    @scopes.last[name.lexeme] = true
  end

  def resolve_local(expr, name)
    @scopes.reverse.each_with_index do |scope, i|
      if scope.key? name.lexeme
        @interpreter.resolve(expr, @scopes.size - 1 - i)
        break
      end
    end

    nil
  end
end
