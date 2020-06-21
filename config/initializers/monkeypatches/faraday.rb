# frozen_string_literal: true

module Faraday
  class << self
    def json_connection(&blk)
      new do |conn|
        conn.request(:json)
        conn.response(:json)
        blk&.call(conn)
      end
    end
  end
end
