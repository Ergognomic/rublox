# frozen_string_literal: true

require_relative 'callable'
require_relative 'environment'

# Lox function class
class LoxFunction < Callable
  def initialize(declaration)
    super
    @declaration = declaration
  end

  def call(interpreter, arguments)
    environment = Environment.new(interpreter.globals)
    @declaration.params.size.times do |p|
      environment.define(@declaration.params[p].lexeme, arguments[p])
    end
    interpreter.execute_block(@declaration.body, environment)

    nil
  end

  def arity
    @declaration.params.size
  end

  def to_string
    "<fn #{declaration.name.lexeme}>"
  end
end
