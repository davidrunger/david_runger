# frozen_string_literal: true

# Define a custom matcher because the `receive_inbound_email` one provided by `rspec-rails` is
# broken. (It still references a `match_to_mailbox` method that's been deleted from Action Mailbox.)
RSpec::Matchers.define(:receive_email) do |email_options|
  match do |inbox_klass|
    mail = RSpec::Rails::MailboxExampleGroup.create_inbound_email(email_options)
    ApplicationMailbox.router.mailbox_for(mail) == inbox_klass
  end

  failure_message do |inbox_klass|
    "expected #{inbox_klass} to be the mailbox for an email #{email_options}"
  end
end
