# frozen_string_literal: true

TrackAssetSizes.all_globs.each do |glob|
  measurements = RedisTimeseries[glob].to_h.to_a
  measurements_to_transfer =
    (measurements.select.with_index { |_, i| i % 10 == 0 } + measurements.last(30)).uniq
  timeseries = Timeseries.find_or_initialize_by(name: glob)
  timeseries.update!(
    measurements: measurements_to_transfer.map { |(time, value)| [Float(time), value] },
  )
end
