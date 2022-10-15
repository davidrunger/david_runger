# frozen_string_literal: true

module Faraday
  class << self
    def json_connection
      new do |conn|
        conn.request(:json)
        conn.response(:json)
      end
    end
  end
end
