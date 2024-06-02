# frozen_string_literal: true

require_relative 'callable'
require_relative 'environment'

# Lox function class
class LoxFunction < Callable
  def initialize(declaration, closure)
    super
    @declaration = declaration
    @closure = closure
  end

  def call(interpreter, arguments)
    environment = Environment.new(@closure)
    @declaration.params.size.times { |p| environment.define(@declaration.params[p].lexeme, arguments[p]) }
    interpreter.execute_block(@declaration.body, environment)
  rescue LoxReturn => ret
    ret.value
  else
    nil
  end

  def arity
    @declaration.params.size
  end

  def to_string
    "<fn #{declaration.name.lexeme}>"
  end
end
