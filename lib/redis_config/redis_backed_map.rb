# frozen_string_literal: true

class RedisConfig::RedisBackedMap
  delegate :[], :key?, :map, to: :memory_store

  def initialize(name)
    @name = name
  end

  def []=(key, value)
    $redis_pool.with { |conn| conn.hset(redis_hash_key, key, value) }
    @memory_store[key] = value
  end

  def delete(key)
    $redis_pool.with { |conn| conn.hdel(redis_hash_key, key) }
    memory_store.delete(key)
  end

  def clear!
    $redis_pool.with { |conn| conn.del(redis_hash_key) }
    @memory_store = nil
  end

  private

  def memory_store
    @memory_store ||= $redis_pool.with { |conn| conn.hgetall(redis_hash_key) }
  end

  def redis_hash_key
    "#{RedisConfig::REDIS_NAMESPACE}:#{@name}-map"
  end
end
