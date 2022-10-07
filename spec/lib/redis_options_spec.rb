# frozen_string_literal: true

load Rails.root.join('lib/redis_options.rb') if $checking_test_coverage

RSpec.describe RedisOptions do
  context 'when not providing a database number' do
    subject(:redis_options) { RedisOptions.new }

    describe '#url' do
      subject(:url) { redis_options.url }

      context 'when Rails.env is "development"', rails_env: :development do
        it 'is a localhost URL ending with "/0"' do
          expect(url).to eq('redis://localhost:6379/0')
        end
      end

      context 'when `Rails` is not defined' do # e.g. when running `bin/clock`
        before { hide_const('Rails') }

        it 'is a localhost URL ending with "/0"' do
          expect(url).to eq('redis://localhost:6379/0')
        end
      end
    end
  end

  context 'when explicitly providing a database number' do
    subject(:redis_options) { RedisOptions.new(db: db_number) }

    let(:db_number) { 2 }

    describe '#url' do
      subject(:url) { redis_options.url }

      context 'when RAILS_ENV is "development"' do
        around { |spec| ClimateControl.modify(RAILS_ENV: 'development') { spec.run } }

        it 'returns a localhost URL with a database path' do
          expect(url).to eq('redis://localhost:6379/2')
        end
      end

      context 'when RAILS_ENV is "production"' do
        around { |spec| ClimateControl.modify(RAILS_ENV: 'production') { spec.run } }

        context 'when a REDIS_URL env var is present' do
          let(:redis_url) { 'redis://:p4ssw0rd@10.0.1.1:6380' }

          around { |spec| ClimateControl.modify(REDIS_URL: redis_url) { spec.run } }

          it 'returns the Redis url with a database path' do
            expect(url).to eq("#{redis_url}/#{db_number}")
          end
        end
      end
    end
  end
end
