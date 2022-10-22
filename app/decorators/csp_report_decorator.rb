# frozen_string_literal: true

class CspReportDecorator < Draper::Decorator
  include UserAgentDecoratable

  delegate_all

  def to_s
    "#{object.class.name} ##{id}"
  end
end
