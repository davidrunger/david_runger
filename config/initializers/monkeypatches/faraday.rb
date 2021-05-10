# frozen_string_literal: true

module Faraday
  class << self
    def json_connection(timeout: 60, &blk)
      new do |conn|
        conn.options.timeout = timeout
        conn.request(:json)
        conn.response(:json)
        blk&.call(conn)
      end
    end
  end
end
