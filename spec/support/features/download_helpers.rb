RSpec.configure do |config|
  config.before(:suite) do
    tmp_dir = Dir.mktmpdir
    @capybara_downloads_tmp_dir = tmp_dir
    Capybara.save_path = tmp_dir
  end
end

module Features::DownloadHelpers
  private

  def downloaded_file_path(relative_glob_pattern, max_attempts: 100, sleep_seconds: 0.05)
    absolute_glob_pattern = File.join(@capybara_downloads_tmp_dir, relative_glob_pattern)

    max_attempts.times do |index|
      matching_paths = Dir.glob(absolute_glob_pattern)

      if (matching_path = matching_paths.first)
        break matching_path
      elsif index == max_attempts - 1
        raise(<<~ERROR.squish)
          Could not find a file matching '#{relative_glob_pattern}' after
          #{max_attempts} attempt(s) with a sleep of #{sleep_seconds} seconds.
        ERROR
      else
        sleep(sleep_seconds)
      end
    end
  end
end
