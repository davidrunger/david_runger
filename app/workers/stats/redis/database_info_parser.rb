# frozen_string_literal: true

# This utility class turns the "raw" `key=value`-formatted string info about Redis databases into a
# parsed hash of info.
class Stats::Redis::DatabaseInfoParser
  extend Memoist

  DEFAULT_DATABASE_STATS = {
    'expires' => 0,
    'keys' => 0,
  }.freeze
  MINIMUM_DATABASES_TO_TRACK = %w[db0 db1].freeze

  def initialize(redis_info_hash)
    @redis_info_hash = redis_info_hash
  end

  def parsed_database_info
    database_keys.map do |database_name|
      database_stats_string = @redis_info_hash[database_name] || ''
      [
        database_name,
        DEFAULT_DATABASE_STATS.merge(database_hash_from_sting(database_stats_string)),
      ]
    end.to_h
  end

  private

  def database_hash_from_sting(database_stats_string)
    database_stats_string.split(',').
      map { |key_value_pair| key_value_pair.split('=').map(&:strip) }.
      to_h.
      transform_values { |value| Integer(value) }
  end

  memoize \
  def database_keys
    keys_from_info =
      @redis_info_hash.keys.select do |key|
        key.match?(/\Adb\d{1,2}\z/) # values like 'db0', 'db1', ..., 'db15'
      end

    (MINIMUM_DATABASES_TO_TRACK + keys_from_info).uniq
  end
end
