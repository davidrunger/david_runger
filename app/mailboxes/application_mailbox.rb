class ApplicationMailbox < ActionMailbox::Base
  LOG_ENTRIES_ROUTING_REGEX =
    %r{\Alog-entries\|log/(?<email_submission_token>[A-Za-z0-9]{#{Log::EMAIL_SUBMISSION_TOKEN_LENGTH}})@mg\.davidrunger\.com\z}i

  routing(LOG_ENTRIES_ROUTING_REGEX => :log_entries, /\Areply@/ => :replies)
end
