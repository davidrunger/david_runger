class ApplicationMailbox < ActionMailbox::Base
  LOG_ENTRIES_ROUTING_REGEX = %r{log-entries\|log/(?<log_id>\d+)@mg\.davidrunger\.com}i

  routing(LOG_ENTRIES_ROUTING_REGEX => :log_entries, /\Areply@/ => :replies)
end
