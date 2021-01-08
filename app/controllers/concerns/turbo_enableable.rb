# frozen_string_literal: true

module TurboEnableable
  extend ActiveSupport::Concern

  private

  def enable_turbo
    @turbo_enabled = true
  end
end
