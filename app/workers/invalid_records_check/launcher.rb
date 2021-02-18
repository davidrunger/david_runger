# frozen_string_literal: true

class InvalidRecordsCheck::Launcher
  prepend ApplicationWorker

  def perform
    # ensure that all model classes are loaded
    Rails.application.eager_load!

    ApplicationRecord.
      descendants.
      reject { _1.descendants.any? }.
      map(&:name).
      sort.
      each_with_index do |klass_name, index|
        InvalidRecordsCheck::Checker.perform_in(index * 10, klass_name)
      end
  end
end
