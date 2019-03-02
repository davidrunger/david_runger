RSpec.describe Api::LogsController do
  before { sign_in(user) }
  let(:user) { users(:user) }

  describe '#create' do
    context 'when the log being created is invalid' do
      let(:invalid_params) { {log: {name: ''}} }

      it 'returns a 422 status code' do
        post(:create, params: invalid_params)
        expect(response.status).to eq(422)
      end
    end
  end
end
