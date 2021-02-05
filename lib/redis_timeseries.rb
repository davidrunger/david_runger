# frozen_string_literal: true

class RedisTimeseries
  SEPARATOR = ':'

  class << self
    def [](timeseries_name)
      new(timeseries_name)
    end
  end

  def initialize(timeseries_name)
    @timeseries_name = timeseries_name
  end

  def to_h
    Hash[
      $redis_pool.
        with { |conn| conn.zrange(@timeseries_name, 0, -1, withscores: true) }.
        map do |value_with_salt, timestamp|
          [Time.at(timestamp).in_time_zone, Integer(value_with_salt.split(SEPARATOR).first)]
        end
    ]
  end

  def add(value)
    $redis_pool.with do |conn|
      conn.zadd(@timeseries_name, (time = Time.current.to_f), "#{value}#{SEPARATOR}#{time}")
    end
  end
end
