# frozen_string_literal: true

class TrackAssetSizes
  extend Memoist

  class << self
    extend Memoist

    def all_globs
      new.track_all_asset_sizes(dry_run: true).keys.sort
    end
  end

  def perform
    track_all_asset_sizes
  end

  def track_all_asset_sizes(dry_run: false)
    accumulator = {}
    packs.each do |pack_name|
      track_asset_sizes(pack_name, accumulator:, dry_run:)
    end
    accumulator
  end

  private

  def track_asset_sizes(pack_name, accumulator:, dry_run:)
    asset_and_js_dependencies = asset_and_js_dependencies("packs/#{pack_name}.js")
    total_js_files_size =
      asset_and_js_dependencies.
        sum { |asset| File.new("public/vite/#{file_name(asset)}").size }

    total_css_files_size =
      asset_and_js_dependencies.map { |asset| manifest[asset]['css'] || [] }.
        flatten.uniq.
        sum { |css_path| File.new("public/vite/#{css_path}").size }

    plain_pack_name = pack_name.delete_suffix('_app')
    js_glob = "#{plain_pack_name}*.js"
    css_glob = "#{plain_pack_name}*.css"

    record_asset_size(js_glob, total_js_files_size, accumulator:, dry_run:)
    record_asset_size(css_glob, total_css_files_size, accumulator:, dry_run:)
  end

  def record_asset_size(glob, files_size, accumulator:, dry_run:)
    if files_size > 1
      accumulator[glob] = files_size
      Timeseries[glob].add(files_size) unless dry_run
    end
  end

  def file_name(asset)
    manifest[asset]['file']
  end

  memoize \
  def asset_and_js_dependencies(asset)
    ([asset] +
      ((manifest[asset]['imports'] || []) + (manifest[asset]['dynamicImports'] || [])).
        map do |imported_file|
          asset_and_js_dependencies(imported_file)
        end.
        flatten
    ).uniq
  end

  memoize \
  def packs
    manifest.
      filter_map do |path, info|
        if info['isEntry']
          path.delete_prefix('packs/').delete_suffix('.js')
        end
      end.
      sort
  end

  memoize \
  def manifest
    JSON.parse(manifest_json)
  end

  memoize \
  def manifest_json
    File.read('public/vite/manifest.json')
  end
end
