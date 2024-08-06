Rails.logger.info("Starting datamigration #{__FILE__.delete_prefix("#{Rails.root}/")} .")

ip_blocks_with_missing_info =
  IpBlock.where(isp: nil).or(
    IpBlock.where(location: nil),
  )

Rails.logger.info("Enqueueing IP info fetches for #{ip_blocks_with_missing_info.size} IpBlocks.")

ip_blocks_with_missing_info.find_each.with_index do |ip_block, index|
  FetchIpInfoForRecord.perform_in(index * 5, ip_block.class.name, ip_block.id)
end

Rails.logger.info("Datamigration #{__FILE__.delete_prefix("#{Rails.root}/")} complete.")
