# frozen_string_literal: true

# Lox runtime error class
class LoxRuntimeError < RuntimeError
  attr_accessor :token

  def initialize(token, message)
    super(message)
    @token = token
  end
end
