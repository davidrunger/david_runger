# frozen_string_literal: true

class FetchLocations
  include Sidekiq::Worker

  def perform
    system('bin/rails requests:fetch_locations') || fail('requests:fetch_locations failed')
  end
end
