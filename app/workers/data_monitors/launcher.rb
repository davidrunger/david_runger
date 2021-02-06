# frozen_string_literal: true

class DataMonitors::Launcher
  prepend ApplicationWorker

  def perform
    # ensure that all `DataMonitors::Base` descendants are loaded
    Rails.application.eager_load!

    DataMonitors::Base.descendants.each_with_index do |data_monitor_worker_klass, index|
      data_monitor_worker_klass.perform_in(index * 10)
    end
  end
end
