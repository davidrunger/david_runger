RSpec.describe Api::WeightLogsController do
  before { sign_in(user) }

  let(:user) { users(:user) }

  describe '#create' do
    context 'when posting valid params' do
      subject(:post_valid_params) { post(:create, params: valid_params) }

      let(:valid_params) do
        {
          weight_log: {
            weight: 167.0,
            note: 'This is the best day of my life.',
          },
        }
      end

      it 'creates a WeightLog record' do
        expect { post_valid_params }.to change(WeightLog, :count).by(1)
      end

      it 'returns a 201 status code' do
        post_valid_params
        expect(response.status).to eq(201)
      end

      it 'responds with JSON of the weight log' do
        post_valid_params

        expected_attributes = %w[created_at id note weight]
        expect(json_response).
          to eq(JSON(WeightLogSerializer.new(WeightLog.order(:created_at).last).to_json))
      end
    end
  end
end
