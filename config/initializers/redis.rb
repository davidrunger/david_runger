unless IS_DOCKER_BUILD
  pool_size = Integer(ENV.fetch('RAILS_MAX_THREADS'))

  $redis_pool =
    RedisClient.
      config(url: RedisOptions.new.url).
      new_pool(size: pool_size)

  # Keep security quota state isolated from general application data in db 0 and Sidekiq in db 1.
  $email_quota_redis_pool =
    RedisClient.
      config(url: RedisOptions.new(db: 2).url).
      new_pool(size: pool_size)
end
