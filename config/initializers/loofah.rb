Loofah::XssFoliate.xss_foliate_all_models

Rails.application.config.to_prepare do
  Blazer::Query.xss_foliate(except: :statement, encode_special_chars: false)
end
