# frozen_string_literal: true

# Lox environment class
class Environment
  def initialize
    @values = {}
  end

  def define(name, value)
    @values[name] = value
  end

  def get(name)
    return @values[name.lexeme] if @values.key? name.lexeme

    raise LoxRuntimeError.new(name, "Undefined variable #{name.lexeme}.")
  end

  def assign(name, value)
    if @values.key? name.lexeme
      @values[name.lexeme] = value
      return
    end
    raise LoxRuntimeError.new(name, "Undefined variable #{name.lexeme}.")
  end
end
