RSpec.describe RedisOptions do
  describe '#url' do
    subject(:url) { redis_options.url }

    context 'when not providing a database number' do
      subject(:redis_options) { RedisOptions.new }

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

    context 'when explicitly providing a database number' do
      subject(:redis_options) { RedisOptions.new(db: db_number) }

      let(:db_number) { 2 }

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

  describe '#default_db_number' do
    subject(:default_db_number) { redis_options.send(:default_db_number) }

    context 'when not providing a database number' do
      subject(:redis_options) { RedisOptions.new }

      context 'when DB_SUFFIX is _unit' do
        around { |spec| ClimateControl.modify(DB_SUFFIX: '_unit') { spec.run } }

        it 'returns 4' do
          expect(default_db_number).to eq(4)
        end
      end

      context 'when DB_SUFFIX is _api' do
        around { |spec| ClimateControl.modify(DB_SUFFIX: '_api') { spec.run } }

        it 'returns 5' do
          expect(default_db_number).to eq(5)
        end
      end

      context 'when DB_SUFFIX is _html' do
        around { |spec| ClimateControl.modify(DB_SUFFIX: '_html') { spec.run } }

        it 'returns 6' do
          expect(default_db_number).to eq(6)
        end
      end

      context 'when DB_SUFFIX is _feature_a' do
        around { |spec| ClimateControl.modify(DB_SUFFIX: '_feature_a') { spec.run } }

        it 'returns 7' do
          expect(default_db_number).to eq(7)
        end
      end

      context 'when DB_SUFFIX is _feature_c' do
        around { |spec| ClimateControl.modify(DB_SUFFIX: '_feature_c') { spec.run } }

        it 'returns 9' do
          expect(default_db_number).to eq(9)
        end
      end

      context 'when DB_SUFFIX is _unexpected' do
        around { |spec| ClimateControl.modify(DB_SUFFIX: '_unexpected') { spec.run } }

        it 'raises an error' do
          expect { default_db_number }.to raise_error('Unexpected DB_SUFFIX!')
        end
      end
    end
  end
end
