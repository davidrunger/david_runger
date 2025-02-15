RSpec.configure do |config|
  config.around(:each, :with_tmp_download_dir) do |spec|
    Dir.mktmpdir do |tmp_dir|
      @capybara_downloads_tmp_dir = tmp_dir

      Capybara.with(save_path: tmp_dir) do
        spec.run
      end
    end
  end
end

module Features::DownloadHelpers
  def downloaded_file_path(relative_glob_pattern, max_attempts: 100, sleep_seconds: 0.05)
    if @capybara_downloads_tmp_dir.nil?
      raise('Apply the :with_tmp_download_dir RSpec metadata to the spec.')
    end

    absolute_glob_pattern = File.join(@capybara_downloads_tmp_dir, relative_glob_pattern)

    max_attempts.times do |index|
      matching_paths = Dir.glob(absolute_glob_pattern)

      if (matching_path = matching_paths.first)
        break matching_path
      elsif index == max_attempts - 1
        raise(<<~ERROR)
          Could not find a file matching '#{relative_glob_pattern}' after
          #{max_attempts} attempt(s) with a sleep of #{sleep_seconds} seconds.
        ERROR
      else
        sleep(sleep_seconds)
      end
    end
  end
end
