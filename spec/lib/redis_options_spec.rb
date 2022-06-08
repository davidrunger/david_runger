# frozen_string_literal: true

RSpec.describe RedisOptions do
  subject(:redis_options) { RedisOptions }

  describe '::options' do
    subject(:options) do
      redis_options.options(db: db_number)
    end

    let(:db_number) { 2 }

    context 'when Rails.env is "development"', rails_env: :development do
      it 'returns a localhost URL' do
        expect(options[:url]).to eq("redis://localhost:6379/#{db_number}")
      end
    end

    context 'when Rails.env is "production"', rails_env: :production do
      context 'when Redis credentials are present' do
        let(:tls_url) { 'rediss://:p4ssw0rd@10.0.1.1:6380' }

        before do
          expect(Rails.application.credentials).to receive(:redis).and_return(tls_url: tls_url)
        end

        it 'returns the redis.tls_url from the Rails credentials' do
          expect(options[:url]).to eq("#{tls_url}/#{db_number}")
        end
      end
    end
  end
end
