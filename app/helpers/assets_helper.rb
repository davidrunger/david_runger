# frozen_string_literal: true

module AssetsHelper
  def admin_js_tag(pack_name)
    js_file_path =
      JSON.parse(File.read('public/vite-admin/manifest.json')).
        dig("admin_packs/#{pack_name}.js", 'file')
    javascript_include_tag("/vite-admin/#{js_file_path}")
  end

  def js_tag(pack_name)
    vite_javascript_tag(pack_name, defer: 'defer', crossorigin: nil)
  end
end
