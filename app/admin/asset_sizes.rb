# frozen_string_literal: true

ActiveAdmin.register_page('Asset Sizes') do
  menu parent: 'Admin'

  content do
    div(js_tag('charts'))

    Timeseries.where(name: TrackAssetSizes.all_globs).each do |timeseries|
      h2(timeseries.name)
      div(line_chart(timeseries.to_h))
    end
  end
end
