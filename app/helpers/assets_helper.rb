module AssetsHelper
  def admin_ts_tag(entrypoint_name)
    # rubocop:disable Layout/LineLength
    # NOTE: To have an auto-reloading dev experience (though no HMR), launch Vite with:
    #   VITE_RUBY_ENTRYPOINTS_DIR=admin_entrypoints VITE_RUBY_PUBLIC_OUTPUT_DIR=vite-admin ./node_modules/.bin/vite dev --force
    # and launch a Rails server with:
    #   VITE_RUBY_ENTRYPOINTS_DIR=admin_entrypoints VITE_RUBY_PUBLIC_OUTPUT_DIR=vite-admin bin/rails server
    # rubocop:enable Layout/LineLength
    if (
      Rails.env.development? &&
        ENV.fetch('VITE_RUBY_ENTRYPOINTS_DIR', nil) == 'admin_entrypoints' &&
        ENV.fetch('VITE_RUBY_PUBLIC_OUTPUT_DIR', nil) == 'vite-admin' &&
        ((Faraday.get(
          "http://localhost:3036/vite-admin/admin_entrypoints/#{entrypoint_name}.ts",
        ).status rescue nil) == 200)
    )
      vite_typescript_tag(entrypoint_name, defer: 'defer', crossorigin: nil)
    else
      data_for_entrypoint =
        JSON.parse(File.read('public/vite-admin/.vite/manifest.json')).
          fetch("admin_entrypoints/#{entrypoint_name}.ts")

      compiled_js_file_path = data_for_entrypoint.fetch('file')
      compiled_css_file_paths = data_for_entrypoint.fetch('css', [])

      javascript_include_tag(
        "/vite-admin/#{compiled_js_file_path}",
        type: 'module',
        defer: 'defer',
        crossorigin: nil,
      ) +
        # rubocop:disable Rails/OutputSafety
        raw(compiled_css_file_paths.
          map { stylesheet_link_tag("/vite-admin/#{it}") }.
          join(''))
      # rubocop:enable Rails/OutputSafety
    end
  end

  def ts_tag(entrypoint_name)
    vite_typescript_tag(entrypoint_name, defer: 'defer', crossorigin: nil)
  end
end
