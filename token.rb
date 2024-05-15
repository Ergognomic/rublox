# frozen_string_literal: true

# Lox token
class Token
  attr_accessor :type, :lexeme, :literal, :line

  def initialize(type, lexeme, literal, line)
    @type = type # token type
    @lexeme = lexeme # string
    @literal = literal # value of token
    @line = line # line number token appears on
  end

  def to_string
    "#{@type} #{@lexeme} #{@literal}"
  end
end
