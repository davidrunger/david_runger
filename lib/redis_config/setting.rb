# frozen_string_literal: true

class RedisConfig::Setting
  attr_reader :name, :type, :value

  def initialize(name:, type:, value:)
    @name = name
    @type = type
    @value = value
  end
end
