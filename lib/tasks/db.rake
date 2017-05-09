namespace :db do
  desc 'Delete all but the most recent rows in the `requests` table'
  task truncate_old_requests: :environment do
    puts "(Possibly) truncating the requests table..."

    num_requests = Request.count
    puts "number of `requests` prior truncation: #{num_requests}"

    max_allowed_rows = Integer(ENV['REQUESTS_MAX_ROWS']) || 4_000
    puts "max allowed rows: #{max_allowed_rows}"

    min_surviving_requested_at =
      case
      when max_allowed_rows > 0
        Request.order(requested_at: :desc).limit(max_allowed_rows).last.requested_at
      else
        Request.maximum(:requested_at) + 1.second
      end
    requests_to_destroy = Request.where('requests.requested_at < ?', min_surviving_requested_at)
    puts <<-LOG.squish
      destroying `requests` requested prior to #{min_surviving_requested_at.utc.iso8601}
      (#{requests_to_destroy.count} such requests)
    LOG
    requests_to_destroy.delete_all

    puts "number of `requests` after truncation: #{Request.count}"
  end

  desc "Clean old logs"
  task :logs => :environment do
    Log.cleanup!
  end

  task :all => [:clicks, :logs]
end
