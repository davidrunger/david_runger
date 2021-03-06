# frozen_string_literal: true

class ApplicationMailbox < ActionMailbox::Base
  LOG_ENTRIES_ROUTING_REGEX = %r{log-entries\|log/(?<log_id>\d+)@mg\.davidrunger\.com}i.freeze
  VOICEMAILS_ROUTING_REGEX =
    %r{voicemails\|auth-secret/(?<auth_token_secret>\S+)@mg\.davidrunger\.com}i.freeze

  routing(
    LOG_ENTRIES_ROUTING_REGEX => :log_entries,
    VOICEMAILS_ROUTING_REGEX => :voicemails,
    /\Areply@/ => :replies,
  )
end
