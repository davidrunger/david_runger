# frozen_string_literal: true

class RedisStats
  extend Memoist
  include Sidekiq::Worker

  sidekiq_options(queue: :essential)

  FLOAT_METRIC_NAMES = %w[
    instantaneous_input_kbps
    instantaneous_output_kbps
    mem_fragmentation_ratio
    rss_overhead_ratio
    used_cpu_sys
    used_cpu_sys_children
    used_cpu_user
    used_cpu_user_children
  ].freeze

  INTEGER_METRIC_NAMES = %w[
    active_defrag_running
    allocator_active
    allocator_allocated
    allocator_resident
    blocked_clients
    client_recent_max_input_buffer
    client_recent_max_output_buffer
    connected_clients
    evicted_keys
    expired_keys
    expired_time_cap_reached_count
    instantaneous_ops_per_sec
    keyspace_hits
    keyspace_misses
    lazyfree_pending_objects
    loading
    maxmemory
    mem_clients_normal
    number_of_cached_scripts
    rdb_bgsave_in_progress
    rdb_changes_since_last_save
    rdb_last_bgsave_time_sec
    rdb_last_save_time
    rejected_connections
    rss_overhead_bytes
    total_commands_processed
    total_connections_received
    total_net_input_bytes
    total_net_output_bytes
    used_memory
    used_memory_dataset
    used_memory_lua
    used_memory_overhead
    used_memory_peak
    used_memory_rss
    used_memory_scripts
    used_memory_startup
  ].freeze

  def perform
    track_integers
    track_floats
    track_databases
    track_connection_pool
  end

  private unless Rails.env.test?

  memoize \
  def info_hash
    $redis_pool.with(&:info)
  end

  def track(metric_name, value)
    StatsD.gauge("redis.#{metric_name}", value)
  end

  def track_integers
    INTEGER_METRIC_NAMES.each do |metric_name|
      track(metric_name, Integer(info_hash[metric_name]))
    end
  end

  def track_floats
    FLOAT_METRIC_NAMES.each do |metric_name|
      track(metric_name, Float(info_hash[metric_name]))
    end
  end

  def track_databases
    # The relevant data in the hash looks like:
    # {
    #   "db0"=>"keys=18,expires=18,avg_ttl=1789848282",
    #   "db1"=>"keys=10,expires=3,avg_ttl=106149604570"
    # }
    database_keys.each do |database|
      database_stats_string = info_hash[database] || ''

      database_stats_hash =
        database_stats_string.split(',').
          map { |key_value_pair| key_value_pair.split('=').map(&:strip) }.
          to_h.
          transform_values { |value| Integer(value) }

      database_stats_hash['keys'] ||= 0
      database_stats_hash['expires'] ||= 0

      database_stats_hash.each do |metric, value|
        track("#{database}.#{metric}", value)
      end
    end
  end

  def track_connection_pool
    track('connection_pool.size', $redis_pool.size)
    track('connection_pool.available', $redis_pool.available)
  end

  memoize \
  def database_keys
    minimum_databases_to_track = %w[db0 db1]
    keys_from_info =
      info_hash.keys.select do |key|
        key.match?(/\Adb\d{1,2}\z/) # values like 'db0', 'db1', ..., 'db16'
      end

    (minimum_databases_to_track + keys_from_info).uniq
  end
end
