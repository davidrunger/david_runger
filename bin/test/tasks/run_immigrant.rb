# frozen_string_literal: true

class Test::Tasks::RunImmigrant < Pallets::Task
  include Test::TaskHelpers

  def run
    require 'immigrant'

    Rake::Task['environment'].invoke
    Immigrant.load

    # The below code is copied (with slight modifications) from the `immigrant:check_keys` rake task
    # in the `immigrant` gem.
    Rails.application.eager_load!

    keys, warnings = Immigrant::KeyFinder.new.infer_keys
    warnings.each_value { |warning| $stderr.puts "WARNING: #{warning}" }

    keys.each do |key|
      column = key.options[:column]
      pk = key.options[:primary_key]
      $stderr.puts(<<~LOG.squish)
        Missing foreign key relationship on '#{key.from_table}.#{column}' to '#{key.to_table}.#{pk}'
      LOG
    end

    if keys.any?
      puts(<<~LOG)
        Found missing foreign keys, run `rails generate immigration MigrationName` to create a
        migration to add them.
      LOG
      update_job_result_exit_code(keys.count)
    else
      update_job_result_exit_code(0)
    end
  end
end
