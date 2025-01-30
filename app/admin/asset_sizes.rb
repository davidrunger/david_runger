ActiveAdmin.register_page('Asset Sizes') do
  menu parent: 'Admin'

  content do
    div(admin_ts_tag('charts.ts'))

    Timeseries.where(name: TrackAssetSizes.all_globs).find_each do |timeseries|
      h2(timeseries.name)
      div(line_chart(timeseries.to_h))
    end
  end
end
