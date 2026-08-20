unless IS_DOCKER_BUILD
  pool_size = Integer(ENV.fetch('RAILS_MAX_THREADS'))

  $redis_pool =
    RedisClient.
      config(url: RedisOptions.new.url).
      new_pool(size: pool_size)
end
