# frozen_string_literal: true

class InvalidRecordsMailer < ApplicationMailer
  def invalid_records(invalid_records_count_hash)
    @invalid_records_count_hash = invalid_records_count_hash
    mail(subject: 'There is at least one invalid record. :(')
  end
end
