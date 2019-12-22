# frozen_string_literal: true

class FetchLocations
  include Sidekiq::Worker

  def perform
    Rake::Task['requests:fetch_locations'].invoke
  end
end
