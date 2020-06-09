# frozen_string_literal: true

module PresenceBangMonkeypatch
  def presence!(error_message = nil)
    if present?
      self
    else
      error_message ||= "Expected object to be `present?` but was #{inspect}"
      raise(error_message)
    end
  end
end

Object.prepend(PresenceBangMonkeypatch)
