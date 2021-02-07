# frozen_string_literal: true

class RedisConfig::Accessor
  def initialize(namespace)
    @namespace = namespace
  end

  def get(key_name, backup_value = nil)
    RedisConfig.get("#{@namespace}.#{key_name}", backup_value).value
  end
end
