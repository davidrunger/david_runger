# frozen_string_literal: true

require 'administrate/field/base'

class PapertrailSearchField < Administrate::Field::Base
  def to_s
    data
  end

  def papertrail_search_url
    "https://my.papertrailapp.com/systems/davidrunger/events?q=#{data}"
  end
end
