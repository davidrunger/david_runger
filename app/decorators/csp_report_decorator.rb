# frozen_string_literal: true

class CspReportDecorator < Draper::Decorator
  include UserAgentDecoratable

  delegate_all
end
