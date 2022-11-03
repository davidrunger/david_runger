# frozen_string_literal: true

module RedisConfig
  REDIS_NAMESPACE = 'redis-config'
  TYPES = %w[integer].map(&:freeze).freeze

  def add(key_name, type)
    key_name_string = key_name.to_s
    type = type.to_s

    if !type.in?(TYPES)
      raise(ArgumentError, %(Type "#{type}" is not supported))
    end

    if types_map.key?(key_name_string)
      raise(ArgumentError, %(Setting "#{key_name}" has already been registered))
    end

    types_map[key_name_string] = type
    setting_for(key_name)
  end

  def set(key_name, value)
    ensure_key_has_been_registered!(key_name)
    values_map[key_name] = typed_value(value, types_map[key_name.to_s])
  end

  def get(key_name, backup_value = nil)
    ensure_key_has_been_registered!(key_name) if backup_value.nil?
    setting_for(key_name, backup_value)
  end

  def all
    types_map.map do |key, type|
      RedisConfig::Setting.new(name: key, type:, value: values_map[key])
    end
  end

  def delete(key_name)
    key_name_string = key_name.to_s

    ensure_key_has_been_registered!(key_name)
    types_map.delete(key_name_string)
    values_map.delete(key_name_string)
    true
  end

  def clear!
    @types_map&.clear!
    @values_map&.clear!

    @types_map = nil
    @values_map = nil
  end

  private

  def setting_for(key_name, backup_value = nil)
    key_name_string = key_name.to_s

    type = types_map[key_name_string]
    raw_value = values_map[key_name_string]

    RedisConfig::Setting.new(
      name: key_name_string,
      type:,
      value: raw_value.present? ? typed_value(raw_value, type) : backup_value,
    )
  end

  def ensure_key_has_been_registered!(key_name)
    if !types_map.key?(key_name.to_s)
      raise(ArgumentError, %(Setting "#{key_name}" has not been registered yet))
    end
  end

  def types_map
    @types_map ||= RedisConfig::RedisBackedMap.new('types')
  end

  def values_map
    @values_map ||= RedisConfig::RedisBackedMap.new('values')
  end

  def typed_value(value, type)
    case type
    when 'integer' then Integer(value)
    else raise("Unexpected type '#{type}' for RedisConfig!")
    end
  end

  extend self
end
