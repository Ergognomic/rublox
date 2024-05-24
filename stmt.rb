# frozen_string_literal: true

# This file was auto-generated by generate_ast.

# Pseudo-interface for classes that visit the AST
class Visitor
  def visit_expression_stmt(*)
    warn 'runtime error: unimplemented function: visit_expression_stmt'
    exit 1
  end

  def visit_print_stmt(*)
    warn 'runtime error: unimplemented function: visit_print_stmt'
    exit 1
  end
end

# Pseudo virtual class for expressions
class Stmt
  def initialize(*) end

  def accept(*)
    warn 'runtime error: unimplemented function: accept'
    exit 1
  end
end

# Represents expression stmt nodes in the AST
class Expression < Stmt
  attr_accessor :expression

  def initialize(expression)
    super
    @expression = expression
  end

  def accept(visitor)
    visitor.visit_expression_stmt(self)
  end
end

# Represents print stmt nodes in the AST
class Print < Stmt
  attr_accessor :expression

  def initialize(expression)
    super
    @expression = expression
  end

  def accept(visitor)
    visitor.visit_print_stmt(self)
  end
end
