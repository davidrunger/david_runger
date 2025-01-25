module PresenceBangMonkeypatch
  class ObjectNotPresent < StandardError ; end

  def presence!(error_message = nil)
    if present?
      self
    else
      error_message ||= "Expected object to be `present?` but was #{inspect}"
      raise(ObjectNotPresent, error_message)
    end
  end
end

Object.prepend(PresenceBangMonkeypatch)
