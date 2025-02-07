class RequestDecorator < Draper::Decorator
  prepend Memoization
  include UserAgentDecoratable

  delegate_all

  def to_s
    "Request #{id} for #{handler}"
  end
end
