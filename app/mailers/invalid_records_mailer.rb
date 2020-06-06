# frozen_string_literal: true

class InvalidRecordsMailer < ApplicationMailer
  def invalid_records(invalid_records_count_hash)
    @nonzero_invalid_record_counts = invalid_records_count_hash.reject { |_key, value| value == 0 }
    mail(subject: 'There is at least one invalid record. :(')
  end
end
