# frozen_string_literal: true

class Api::CspReportsController < ApplicationController
  extend Memoist

  skip_before_action :authenticate_user!, only: %i[create]
  # The browser submitting the report will not have any CSRF token
  skip_before_action :verify_authenticity_token, only: %i[create]

  def create
    skip_authorization

    Rollbar.error(Error.new(CspViolation), csp_report_params:)

    csp_report =
      CspReport.new do |report|
        report.blocked_uri = csp_report_params['blocked-uri']
        report.document_uri = csp_report_params['document-uri']
        report.ip = request.remote_ip
        report.original_policy = csp_report_params['original-policy']
        report.referrer = csp_report_params['referrer']
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
end
