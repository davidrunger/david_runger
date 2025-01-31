module AssetsHelper
  def admin_ts_tag(pack_name)
    js_file_path =
      JSON.parse(File.read('public/vite-admin/.vite/manifest.json')).
        dig("admin_entrypoints/#{pack_name}.ts", 'file')
    javascript_include_tag("/vite-admin/#{js_file_path}")
  end

  def ts_tag(pack_name)
    vite_typescript_tag(pack_name, defer: 'defer', crossorigin: nil)
  end
end
