# frozen_string_literal: true

module JavascriptHelper
  def js_tag(pack_name)
    if use_vite?
      vite_javascript_tag(pack_name)
    else
      javascript_pack_tag(pack_name, defer: true)
    end
  end

  def use_vite?
    Rails.env.development? && !ENV.key?('USE_WEBPACK')
  end
end
