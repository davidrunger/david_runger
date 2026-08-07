class Api::CspReportsController < Api::BaseController
  prepend Memoization

  skip_before_action :authenticate_user!, only: %i[create]
  # The browser submitting the report will not have any CSRF token
  skip_before_action :verify_authenticity_token, only: %i[create]

  def create
    skip_authorization

    return head :bad_request unless csp_report_params.is_a?(Hash)
    return head :unprocessable_content unless document_uri_from_request_origin?

    csp_report =
      CspReport.new do |report|
        report.blocked_uri = csp_report_params['blocked-uri']
        report.document_uri = csp_report_params['document-uri']
        report.ip = request.remote_ip
        report.original_policy = csp_report_params['original-policy']
        report.referrer = csp_report_params['referrer']
        report.user_agent = request.user_agent
        report.violated_directive = csp_report_params['violated-directive']
      end

    if csp_report.save
      head :no_content
    else
      head :unprocessable_content
    end
  rescue JSON::ParserError
    head :bad_request
  end

  private

  memoize \
  def csp_report_params
    JSON.parse(request.raw_post)['csp-report']
  end

  def document_uri_from_request_origin?
    origin_for(csp_report_params['document-uri']).then do |document_origin|
      document_origin.present? && document_origin == origin_for(request.base_url)
    end
  end

  def origin_for(url)
    uri = URI.parse(url.to_s)
    return unless uri.is_a?(URI::HTTP) && uri.host.present?

    [uri.scheme.downcase, uri.host.downcase, uri.port]
  rescue URI::InvalidURIError
    nil
  end
end
