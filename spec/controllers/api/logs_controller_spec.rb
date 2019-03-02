RSpec.describe Api::LogsController do
  before { sign_in(user) }
  let(:user) { users(:user) }

  describe '#create' do
    context 'when the log being created is invalid' do
      let(:invalid_params) { {log: {name: ''}} }

      it 'logs info about the log and why it is invalid' do
        allow(Rails.logger).to receive(:info).and_call_original

        post(:create, params: invalid_params)

        expect(Rails.logger).
          to have_received(:info).
          with(/Failed to create log. errors={:name=>"can't be blank"} log={.*"name"=>"".*}/)
      end

      it 'returns a 422 status code' do
        post(:create, params: invalid_params)
        expect(response.status).to eq(422)
      end
    end
  end
end
