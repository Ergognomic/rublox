# frozen_string_literal: true

require_relative 'callable'

# Lox clock() function class
class Clock < Callable
  def call
    Time.now.to_f
  end

  def arity
    0
  end

  def to_string
    '<native fn>'
  end
end
