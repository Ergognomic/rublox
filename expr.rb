# frozen_string_literal: true

# This file was auto-generated by generate_ast.

# Pseudo-interface for classes that visit the AST
class Visitor
  def visit_binary_expr(*)
    warn 'runtime error: unimplemented function: visit_binary_expr'
    exit 1
  end

  def visit_grouping_expr(*)
    warn 'runtime error: unimplemented function: visit_grouping_expr'
    exit 1
  end

  def visit_literal_expr(*)
    warn 'runtime error: unimplemented function: visit_literal_expr'
    exit 1
  end

  def visit_unary_expr(*)
    warn 'runtime error: unimplemented function: visit_unary_expr'
    exit 1
  end
end

# Pseudo virtual class for expressions
class Expr
  def initialize(*) end

  def accept(*)
    warn 'runtime error: unimplemented function: accept'
    exit 1
  end
end

# Represents binary expression nodes in the AST
class Binary < Expr
  attr_accessor :left, :operator, :right

  def initialize(left, operator, right)
    super
    @left = left
    @operator = operator
    @right = right
  end

  def accept(visitor)
    visitor.visit_binary_expr(self)
  end
end

# Represents grouping expression nodes in the AST
class Grouping < Expr
  attr_accessor :expression

  def initialize(expression)
    super
    @expression = expression
  end

  def accept(visitor)
    visitor.visit_grouping_expr(self)
  end
end

# Represents literal expression nodes in the AST
class Literal < Expr
  attr_accessor :value

  def initialize(value)
    super
    @value = value
  end

  def accept(visitor)
    visitor.visit_literal_expr(self)
  end
end

# Represents unary expression nodes in the AST
class Unary < Expr
  attr_accessor :operator, :right

  def initialize(operator, right)
    super
    @operator = operator
    @right = right
  end

  def accept(visitor)
    visitor.visit_unary_expr(self)
  end
end
