class Api::CspReportsController < Api::BaseController
  prepend Memoization

  IGNORED_USER_AGENTS = [
    /DuckDuckBot/,
  ].freeze

  skip_before_action :authenticate_user!, only: %i[create]
  # The browser submitting the report will not have any CSRF token
  skip_before_action :verify_authenticity_token, only: %i[create]

  def create
    skip_authorization

    if send_csp_violation_to_rollbar?
      Rails.error.report(
        Error.new(CspViolation),
        severity: :info,
        context: { csp_report_params: },
      )
    end

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
    csp_report.save!

    head :no_content
  end

  private

  memoize \
  def csp_report_params
    JSON(request.raw_post)['csp-report']
  end

  memoize \
  def send_csp_violation_to_rollbar?
    IGNORED_USER_AGENTS.none? { request.user_agent.match?(_1) }
  end
end
