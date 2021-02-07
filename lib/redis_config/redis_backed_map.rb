# frozen_string_literal: true

class RedisConfig::RedisBackedMap
  delegate :[], :key?, :map, to: :memory_store

  def initialize(name)
    @name = name
  end

  def []=(key, value)
    $redis_pool.with { |conn| conn.hset(namespace, key, value) }
    memory_store[key] = value
  end

  def delete(key)
    $redis_pool.with { |conn| conn.hdel(namespace, key) }
    memory_store.delete(key)
  end

  def clear!
    $redis_pool.with { |conn| conn.del(namespace) }
    RequestStore.store[namespace] = nil
  end

  private

  def memory_store
    RequestStore.store[namespace] ||= $redis_pool.with { |conn| conn.hgetall(namespace) }
  end

  def namespace
    "#{RedisConfig::REDIS_NAMESPACE}:#{@name}-map"
  end
end
