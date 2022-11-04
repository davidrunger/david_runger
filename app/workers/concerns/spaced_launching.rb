# frozen_string_literal: true

module SpacedLaunching
  private

  def launch_with_spacing(worker_name:, arguments_list:, spacing_seconds:)
    arguments_list.each_with_index do |arguments, index|
      worker_name.constantize.perform_in((index + 1) * spacing_seconds, *Array(arguments))
    end
  end
end
