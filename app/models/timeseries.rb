# == Schema Information
#
# Table name: timeseries
#
#  created_at   :datetime         not null
#  id           :bigint           not null, primary key
#  measurements :jsonb            not null
#  name         :text             not null
#  updated_at   :datetime         not null
#
class Timeseries < ApplicationRecord
  validates :name, presence: true
  validates :measurements, presence: true

  class << self
    def [](timeseries_name)
      Timeseries.find_or_initialize_by(name: timeseries_name)
    end
  end

  def to_h
    measurements.
      to_h do |(time_as_float, value)|
        [Time.at(time_as_float).in_time_zone, value]
      end
  end

  def add(value)
    measurements << [Time.current.to_f, value]
    save!
  end
end
