require 'administrate/field/base'

class IpAddressField < Administrate::Field::Base
  def to_s
    data
  end

  def spiceworks_ip_url
    "https://community.spiceworks.com/tools/ip-lookup/results?hostname=#{data}"
  end
end
