require 'administrate/field/base'

class IpAddressField < Administrate::Field::Base
  def to_s
    data
  end
end
