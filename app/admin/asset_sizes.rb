ActiveAdmin.register_page('Asset Sizes') do
  menu parent: 'Admin'

  content do
    Timeseries.where(name: TrackAssetSizes.all_globs).find_each do |timeseries|
      h2(timeseries.name)
      div(line_chart(timeseries.to_h))
    end
  end
end
