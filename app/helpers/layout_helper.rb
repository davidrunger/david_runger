module LayoutHelper
  def webpack_dev_server_present?
    Rails.env.development? && Net::HTTP.get(URI("http://localhost:8080")) ? true : false
  rescue Errno::ECONNREFUSED
    return false
  end
end
