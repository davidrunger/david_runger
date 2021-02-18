# frozen_string_literal: true

class InvalidRecordsMailer < ApplicationMailer
  def invalid_records(klass_name, number_of_invalid_records)
    @klass_name = klass_name
    @number_of_invalid_records = number_of_invalid_records
    mail(subject: "There are #{@number_of_invalid_records} invalid #{@klass_name}s. :(")
  end
end
