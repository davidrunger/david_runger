# frozen_string_literal: true

ActiveAdmin.register_page('Asset Sizes') do
  menu parent: 'Admin'

  content do
    div(js_tag('charts'))

    TrackAssetSizes.all_globs.each do |glob|
      h2(glob)
      div(line_chart(Timeseries[glob].to_h))
    end
  end
end
