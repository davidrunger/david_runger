# frozen_string_literal: true

class CspViolation < StandardError
  def initialize(message = nil)
    super(message || 'Content Security Policy violation')
  end
end
