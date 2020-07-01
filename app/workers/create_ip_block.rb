# frozen_string_literal: true

class CreateIpBlock
  prepend ApplicationWorker

  def perform(ip)
    ip_block = IpBlock.find_or_initialize_by(ip: ip)
    if ip_block.new_record?
      block_reason =
        $redis_pool.
          with { |conn| conn.hgetall("blocked-requests:#{ip}") }.
          transform_values { Integer(_1) }.
          select { |_path, unix_time| unix_time >= Integer(Rack::Attack::PENTESTING_FINDTIME.ago) }.
          map { |path, unix_time| "#{path} (at #{Time.zone.at(unix_time)})" }.
          join("\n")
      ip_block.update!(reason: block_reason)
    end
  end
end
