ip_blocks_with_missing_info =
  IpBlock.where(isp: nil).or(
    IpBlock.where(location: nil)
  )

ip_blocks_with_missing_info.find_each.with_index do |ip_block, index|
  FetchIpInfoForRecord.perform_in(index * 5, ip_block.class.name, ip_block.id)
end
