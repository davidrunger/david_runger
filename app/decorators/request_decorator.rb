class RequestDecorator < Draper::Decorator
  include UserAgentDecoratable

  delegate_all

  def to_s
    "Request #{id} for #{handler}"
  end
end
