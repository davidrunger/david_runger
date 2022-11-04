# frozen_string_literal: true

module SpacedLaunching
  class ApplicationWorker::MaxSpacingTimeExceeded < StandardError ; end

  MAX_TOTAL_SPACING = 3.hours

  private

  def launch_with_spacing(worker_name:, arguments_list:, spacing_seconds:)
    warn_if_total_spacing_too_large(arguments_list:, spacing_seconds:)

    arguments_list.each_with_index do |arguments, index|
      worker_name.constantize.perform_in((index + 1) * spacing_seconds, *Array(arguments))
    end
  end

  def warn_if_total_spacing_too_large(arguments_list:, spacing_seconds:)
    total_spacing = arguments_list.size * spacing_seconds
    if total_spacing > MAX_TOTAL_SPACING
      Rollbar.warn(
        Error.new(ApplicationWorker::MaxSpacingTimeExceeded),
        max_total_spacing: MAX_TOTAL_SPACING,
        spacing_seconds:,
        arguments_list:,
      )
    end
  end
end
