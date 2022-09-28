# frozen_string_literal: true

module MailSpecHelpers
  def mail_from_raw_email_fixture(fixture_name)
    Mail.new(File.read("spec/fixtures/raw_emails/#{fixture_name}.eml"))
  end

  def route_raw_email_fixture(fixture_name)
    create_inbound_email_from_source(
      File.read("spec/fixtures/raw_emails/#{fixture_name}.eml"),
      status: :processing,
    ).tap(&:route)
  end
end
