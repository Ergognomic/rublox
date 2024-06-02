# frozen_string_literal: true

# Exception used for returning function values
class LoxReturn < RuntimeError
  attr_accessor :value

  def initialize(value)
    super(nil)
    @value = value
  end
end
