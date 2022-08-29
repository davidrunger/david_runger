# frozen_string_literal: true

RSpec.describe RedisOptions do
  subject(:redis_options) { RedisOptions.new(db: db_number) }

  let(:db_number) { 2 }

  describe '#url' do
    subject(:url) { redis_options.url }

    context 'when Rails.env is "development"', rails_env: :development do
      it 'returns a localhost URL with a database path' do
        expect(url).to eq('redis://localhost:6379/2')
      end
    end

    context 'when Rails.env is "production"', rails_env: :production do
      context 'when Redis credentials are present' do
        let(:redis_url) { 'redis://:p4ssw0rd@10.0.1.1:6380' }

        around { |spec| ClimateControl.modify(REDIS_URL: redis_url) { spec.run } }

        it 'returns the Redis url with a database path' do
          expect(url).to eq("#{redis_url}/#{db_number}")
        end
      end
    end
  end
end
