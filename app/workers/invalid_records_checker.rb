# frozen_string_literal: true

class InvalidRecordsChecker
  prepend ApplicationWorker

  def perform
    # ensure that all model classes are loaded
    Rails.application.eager_load!

    invalid_records_count_hash =
      ApplicationRecord.
        descendants.
        reject { _1.descendants.any? }.
        map(&:name).
        sort.
        index_with do |klass_name|
          klass_name.constantize.find_each.count { |record| !record.valid? }
        end

    total_number_of_invalid_records = invalid_records_count_hash.values.sum
    if total_number_of_invalid_records > 0
      InvalidRecordsMailer.invalid_records(invalid_records_count_hash).deliver_later
    end
  end
end
