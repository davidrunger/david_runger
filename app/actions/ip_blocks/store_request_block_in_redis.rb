# frozen_string_literal: true

class IpBlocks::StoreRequestBlockInRedis < ApplicationAction
  requires :ip, String, format: { with: /[.:0-9a-z]{7,39}/ }
  requires :path, String, format: { with: %r{\A/} }

  def execute
    $redis_pool.with do |conn|
      conn.hset(redis_hash_key, path, Time.current.to_i)
      conn.expire(redis_hash_key, Integer(Rack::Attack::PENTESTING_FINDTIME))
    end
  end

  private

  def redis_hash_key
    "blocked-requests:#{ip}"
  end
end
