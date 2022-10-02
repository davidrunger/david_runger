# frozen_string_literal: true

# Errors created via `MyErrorClass.new('a message')` don't have a backtrace.
# This enables conveniently creating errors w/ a backtrace:
#
# Example:
#   Error.new(MyErrorClass, 'a message')
module Error
  class << self
    def new(error_klass, message = nil)
      error = error_klass.new(message)
      error.set_backtrace(caller)
      error
    end
  end
end
