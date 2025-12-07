require 'spec_helper'

RSpec.describe ActiveSupport::Cache::RedisCacheStore do
  let(:redis_cache_store) { ActiveSupport::Cache::RedisCacheStore.new }

  it 'writes and reads a value from the Redis cache store' do
    key = "redis_cache_store_spec.rb-#{SecureRandom.alphanumeric}"
    value = SecureRandom.alphanumeric

    expect(redis_cache_store.write(key, value)).to eq(true)
    expect(redis_cache_store.read(key)).to eq(value)

    # Clean up
    redis_cache_store.delete(key)
  end
end
