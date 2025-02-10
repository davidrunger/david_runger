class IpBlocks::StoreRequestBlockInRedis < ApplicationAction
  requires :ip, String, format: { with: /\A[.:0-9a-f]{3,39}\z/ }
  requires :path, String, format: { with: %r{\A/} }

  def execute
    $redis_pool.with do |conn|
      conn.call('hset', redis_hash_key, path, Time.current.to_i)
      conn.call('expire', redis_hash_key, Integer(Rack::Attack::PENTESTING_FINDTIME))
    end
  end

  private

  def redis_hash_key
    "blocked-requests:#{ip}"
  end
end
