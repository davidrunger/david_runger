# frozen_string_literal: true

RSpec.describe Api::LogsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: params) }

    context 'when the log being created is valid' do
      let(:valid_params) do
        {
          log: {
            name: 'Resting Heart Rate',
            data_label: 'Heart Rate',
            data_type: 'number',
          },
        }
      end
      let(:params) { valid_params }

      it 'returns a 201 status code' do
        post_create
        expect(response.status).to eq(201)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'responds with the log as JSON' do
        post_create
        expect(response.parsed_body).to include(
          'data_label' => 'Heart Rate',
          'data_type' => 'number',
          'description' => nil,
          'id' => Integer,
          'name' => 'Resting Heart Rate',
          'slug' => 'resting-heart-rate',
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when the log being created is invalid' do
      let(:invalid_params) { {log: {name: ''}} }
      let(:params) { invalid_params }

      # rubocop:disable RSpec/MultipleExpectations
      it 'logs info about the log and why it is invalid' do
        allow(Rails.logger).to receive(:info).and_call_original

        post_create

        expect(Rails.logger).to have_received(:info) do |logged_string|
          break if logged_string.include?('method=POST path=/api/logs')

          expect(logged_string).to match(/Failed to create log\./)
          expect(logged_string).to match(/errors={.*:name=>\["can't be blank"\].*}/)
          expect(logged_string).to match(/attributes={.*"name"=>"".*}/)
        end
      end
      # rubocop:enable RSpec/MultipleExpectations

      it 'returns a 422 status code' do
        post_create
        expect(response.status).to eq(422)
      end
    end
  end
end
