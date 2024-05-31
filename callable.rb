# frozen_string_literal: true

# Lox callable function abstract class
class Callable
  def call(*)
    raise NotImplementedError, 'unimplemented function: call'
  end

  def arity
    raise NotImplementedError, 'unimplemented function: arity'
  end
end
