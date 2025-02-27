module WindowDataHelper
  def window_data_script_tag
    # rubocop:disable Rails/OutputSafety
    javascript_tag(<<~JS.rstrip, nonce: true)
      window.davidrunger = {env: '#{Rails.env}'};
      window.davidrunger.bootstrap = JSON.parse("#{raw(escape_javascript(schema_validated_data(bootstrap).to_json))}");
    JS
    # rubocop:enable Rails/OutputSafety
  end
end
