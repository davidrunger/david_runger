# frozen_string_literal: true

RSpec.describe(Faraday) do
  describe '::json_connection' do
    subject(:json_connection) { Faraday.json_connection }

    it 'returns an instance of Faraday::Connection configured for JSON requests and responses' do
      expect(json_connection).to be_instance_of(Faraday::Connection)
      expect(json_connection.builder.handlers.map(&:name)).
        to match_array([
          Faraday::Request::Json,
          Faraday::Response::Json,
        ].map(&:name))
    end
  end
end
