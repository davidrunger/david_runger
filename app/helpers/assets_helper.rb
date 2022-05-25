# frozen_string_literal: true

module AssetsHelper
  def js_tag(pack_name)
    vite_javascript_tag(pack_name, defer: 'defer', crossorigin: nil)
  end
end
