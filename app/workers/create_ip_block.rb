class CreateIpBlock
  prepend ApplicationWorker

  unique_while_executing!

  def perform(ip, reason = nil)
    ip_block = IpBlock.find_or_initialize_by(ip:)

    if ip_block.new_record?
      block_reason =
        reason ||
        $redis_pool.
          with { |conn| conn.call('hgetall', "blocked-requests:#{ip}") }.
          transform_values { Integer(it) }.
          filter_map do |path, unix_time|
            "#{path} (at #{Time.zone.at(unix_time)})"
          end.
          join("\n")

      ip_block.update!(reason: block_reason)
      FetchIpInfoForRecord.perform_async(ip_block.class.name, ip_block.id)
    end
  end
end
