# frozen_string_literal: true

class RedisConfig::SettingDecorator < Draper::Decorator
  include ActiveModel::Conversion

  delegate_all

  class << self
    def model_name
      ActiveModel::Name.new(RedisConfig::Setting)
    end
  end
end
