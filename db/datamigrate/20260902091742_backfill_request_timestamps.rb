# Run locally:
#   bin/rails runner db/datamigrate/20260902091742_backfill_request_timestamps.rb
#
# Run in production after this datamigration deploys:
#   bin/run-datamigration db/datamigrate/20260902091742_backfill_request_timestamps.rb

class BackfillRequestTimestamps < Datamigration::Base
  BATCH_SIZE = 1_000

  class IncompleteBackfill < StandardError; end

  def run
    log("Backfilling #{requests_missing_timestamps.count} Requests.")

    requests_missing_timestamps.in_batches(of: BATCH_SIZE).each_with_index do |batch, index|
      # rubocop:disable-next Rails/SkipsModelValidations
      updated_count = batch.update_all(<<~SQL.squish)
        created_at = COALESCE(created_at, requested_at),
        updated_at = COALESCE(updated_at, requested_at)
      SQL

      log("Backfilled batch #{index + 1} (#{updated_count} Requests).")
    end

    remaining_count = requests_missing_timestamps.count
    if remaining_count.positive?
      raise(IncompleteBackfill, "#{remaining_count} Requests still have missing timestamps")
    end
  end

  private

  def requests_missing_timestamps
    Request.where(created_at: nil).or(Request.where(updated_at: nil))
  end
end

Datamigration::Runner.new(BackfillRequestTimestamps).run
