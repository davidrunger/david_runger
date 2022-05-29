# frozen_string_literal: true

class PostgresTimeseries
  class << self
    def [](timeseries_name)
      new(timeseries_name)
    end
  end

  def initialize(timeseries_name)
    @timeseries = Timeseries.find_or_initialize_by(name: timeseries_name)
  end

  def to_h
    @timeseries.measurements.
      to_h do |(time_as_float, value)|
        [Time.at(time_as_float).in_time_zone, value]
      end
  end

  def add(value)
    measurements = @timeseries.measurements
    measurements << [Time.current.to_f, value]
    @timeseries.update!(measurements: measurements)
  end
end
