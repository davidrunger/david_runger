RSpec.configure do |config|
  config.before(:suite) do
    tmp_dir = Dir.mktmpdir
    Capybara.save_path = tmp_dir
  end

  config.before(:each, type: :feature) do
    @capybara_saved_file_states_before_example =
      Dir.glob(File.join(Capybara.save_path, '**', '*')).
        select { |path| File.file?(path) }.
        index_with { |path| capybara_saved_file_state(path) }
  end
end

module Features::DownloadHelpers
  private

  def downloaded_file_path(
    relative_glob_pattern,
    download_element: nil,
    max_attempts: 100,
    sleep_seconds: 0.05,
    &download
  )
    download_attempt =
      if download
        capture_download_attempt(download_element:, &download)
      end

    absolute_glob_pattern = File.join(Capybara.save_path, relative_glob_pattern)

    max_attempts.times do |index|
      matching_path =
        Dir.glob(absolute_glob_pattern).find do |path|
          @capybara_saved_file_states_before_example[path] != capybara_saved_file_state(path)
        end

      if matching_path
        break matching_path
      elsif index == max_attempts - 1
        error_message = <<~ERROR.squish
          Could not find a file matching '#{relative_glob_pattern}' after
          #{max_attempts} attempt(s) with a sleep of #{sleep_seconds} seconds.
        ERROR

        if download_attempt
          diagnostics = download_failure_diagnostics(download_attempt)
          Rails.logger.error("[Capybara download] failed diagnostics=#{diagnostics.inspect}")
          error_message += " Diagnostics: #{diagnostics.inspect}"
        end

        raise(error_message)
      else
        sleep(sleep_seconds)
      end
    end
  end

  def capture_download_attempt(download_element:)
    browser = page.driver.browser
    attempt = {
      download_event_count_before: browser.downloads.files.size,
      element_before_action: download_element_state(download_element),
      network_exchange_count_before: page.driver.network_traffic(:all).size,
    }
    Rails.logger.info("[Capybara download] action starting details=#{attempt.inspect}")
    wait_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    browser.downloads.wait(RSpec.configuration.wait_timeout) do
      action_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      action_result = yield
      attempt[:action_duration_seconds] = elapsed_seconds(action_started_at)
      attempt[:action_result] = download_action_result(action_result)
      attempt[:element_after_action] = download_element_state(download_element)
      Rails.logger.info("[Capybara download] action completed details=#{attempt.inspect}")
    end

    attempt[:download_wait_duration_seconds] = elapsed_seconds(wait_started_at)
    attempt
  end

  def download_action_result(action_result)
    if action_result.is_a?(Capybara::Node::Element)
      download_element_description(action_result)
    else
      { class: action_result.class.name, value: action_result.inspect }
    end
  end

  def download_element_state(element)
    if element
      download_element_description(element).merge(
        bounding_rect: page.evaluate_script(
          <<~JS,
            ((element) => {
              const rect = element.getBoundingClientRect();
              return {
                height: rect.height,
                page_left: rect.left + window.scrollX,
                page_top: rect.top + window.scrollY,
                scroll_x: window.scrollX,
                scroll_y: window.scrollY,
                viewport_left: rect.left,
                viewport_top: rect.top,
                width: rect.width,
              };
            })(arguments[0])
          JS
          element,
        ),
      )
    end
  rescue StandardError => error
    {
      class: element.class.name,
      diagnostics_error: "#{error.class}: #{error.message}",
    }
  end

  def download_element_description(element)
    description = element.base.description

    {
      attributes: Array(description['attributes']).each_slice(2).to_h,
      backend_node_id: description['backendNodeId'],
      class: element.class.name,
      node_id: description['nodeId'],
      node_name: description['nodeName'],
    }
  rescue StandardError => error
    {
      class: element.class.name,
      diagnostics_error: "#{error.class}: #{error.message}",
    }
  end

  def download_failure_diagnostics(download_attempt)
    browser = page.driver.browser

    download_attempt.merge(
      changed_saved_files: changed_capybara_saved_files,
      current_url: page.current_url,
      new_download_events: browser.downloads.files.drop(
        download_attempt.fetch(:download_event_count_before),
      ),
      new_network_exchanges: page.
        driver.
        network_traffic(:all).
        drop(download_attempt.fetch(:network_exchange_count_before)).
        map { |exchange| download_network_exchange_description(exchange) },
    )
  rescue StandardError => error
    download_attempt.merge(
      diagnostics_error: "#{error.class}: #{error.message}",
    )
  end

  def download_network_exchange_description(exchange)
    {
      error: exchange.error&.error_text,
      method: exchange.request&.method,
      pending: exchange.pending?,
      resource_type: exchange.request&.type,
      status: exchange.response&.status,
      url: exchange.url,
    }
  end

  def changed_capybara_saved_files
    paths = Dir.glob(File.join(Capybara.save_path, '**', '*')).select { |path| File.file?(path) }

    paths.filter_map do |path|
      state_after = capybara_saved_file_state(path)
      state_before = @capybara_saved_file_states_before_example.fetch(path, nil)

      if state_after != state_before
        {
          path: path.delete_prefix("#{Capybara.save_path}/"),
          state_after:,
          state_before:,
        }
      end
    end
  end

  def elapsed_seconds(started_at)
    (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at).round(3)
  end

  def capybara_saved_file_state(path)
    stat = File.stat(path)
    [stat.ino, stat.size, stat.mtime.iso8601(9), stat.ctime.iso8601(9)]
  end
end
