# frozen_string_literal: true

class RequestDecorator < Draper::Decorator
  include Memery
  include UserAgentDecoratable

  delegate_all

  def to_s
    "Request #{id} for #{handler}"
  end
end
