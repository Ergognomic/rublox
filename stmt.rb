# frozen_string_literal: true

# This file was auto-generated by generate_ast.

# Pseudo-interface for classes that visit the AST
class Visitor
  def visit_block_stmt(*)
    warn 'runtime error: unimplemented function: visit_block_stmt'
    exit 1
  end

  def visit_expression_stmt(*)
    warn 'runtime error: unimplemented function: visit_expression_stmt'
    exit 1
  end

  def visit_function_stmt(*)
    warn 'runtime error: unimplemented function: visit_function_stmt'
    exit 1
  end

  def visit_if_stmt(*)
    warn 'runtime error: unimplemented function: visit_if_stmt'
    exit 1
  end

  def visit_print_stmt(*)
    warn 'runtime error: unimplemented function: visit_print_stmt'
    exit 1
  end

  def visit_return_stmt(*)
    warn 'runtime error: unimplemented function: visit_return_stmt'
    exit 1
  end

  def visit_var_stmt(*)
    warn 'runtime error: unimplemented function: visit_var_stmt'
    exit 1
  end

  def visit_while_stmt(*)
    warn 'runtime error: unimplemented function: visit_while_stmt'
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

# Represents block stmt nodes in the AST
class Block < Stmt
  attr_accessor :statements

  def initialize(statements)
    super
    @statements = statements
  end

  def accept(visitor)
    visitor.visit_block_stmt(self)
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

# Represents function stmt nodes in the AST
class Function < Stmt
  attr_accessor :name, :params, :body

  def initialize(name, params, body)
    super
    @name = name
    @params = params
    @body = body
  end

  def accept(visitor)
    visitor.visit_function_stmt(self)
  end
end

# Represents if stmt nodes in the AST
class If < Stmt
  attr_accessor :condition, :then_branch, :else_branch

  def initialize(condition, then_branch, else_branch)
    super
    @condition = condition
    @then_branch = then_branch
    @else_branch = else_branch
  end

  def accept(visitor)
    visitor.visit_if_stmt(self)
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

# Represents return stmt nodes in the AST
class Return < Stmt
  attr_accessor :keyword, :value

  def initialize(keyword, value)
    super
    @keyword = keyword
    @value = value
  end

  def accept(visitor)
    visitor.visit_return_stmt(self)
  end
end

# Represents var stmt nodes in the AST
class Var < Stmt
  attr_accessor :name, :initializer

  def initialize(name, initializer)
    super
    @name = name
    @initializer = initializer
  end

  def accept(visitor)
    visitor.visit_var_stmt(self)
  end
end

# Represents while stmt nodes in the AST
class While < Stmt
  attr_accessor :condition, :body

  def initialize(condition, body)
    super
    @condition = condition
    @body = body
  end

  def accept(visitor)
    visitor.visit_while_stmt(self)
  end
end
