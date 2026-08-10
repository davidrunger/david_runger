RSpec.configure do |config|
  config.before(:suite) do
    tmp_dir = Dir.mktmpdir
    Capybara.save_path = tmp_dir
  end

  config.before(:each, type: :feature) do
    @preexisting_capybara_save_paths = Dir.glob(
      File.join(Capybara.save_path, '**', '*'),
    )
  end
end

module Features::DownloadHelpers
  private

  def downloaded_file_path(relative_glob_pattern, max_attempts: 100, sleep_seconds: 0.05)
    absolute_glob_pattern = File.join(Capybara.save_path, relative_glob_pattern)

    max_attempts.times do |index|
      matching_paths = Dir.glob(absolute_glob_pattern) - @preexisting_capybara_save_paths

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
