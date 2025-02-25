class EventDecorator < Draper::Decorator
  include UserAgentDecoratable

  delegate_all

  def to_s
    "#{type.capitalize} Event #{id}"
  end
end
