module AssetsHelper
  def admin_style_tag(entrypoint_file_name)
    compiled_css_file_path =
      JSON.parse(File.read('public/vite-admin/.vite/manifest.json')).
        dig("admin_entrypoints/#{entrypoint_file_name}", 'file')

    stylesheet_link_tag("/vite-admin/#{compiled_css_file_path}")
  end

  def admin_ts_tag(entrypoint_file_name)
    compiled_js_file_path =
      JSON.parse(File.read('public/vite-admin/.vite/manifest.json')).
        dig("admin_entrypoints/#{entrypoint_file_name}", 'file')

    javascript_include_tag(
      "/vite-admin/#{compiled_js_file_path}",
      type: 'module',
      defer: 'defer',
      crossorigin: nil,
    )
  end

  def ts_tag(entrypoint_name)
    vite_typescript_tag(entrypoint_name, defer: 'defer', crossorigin: nil)
  end
end
