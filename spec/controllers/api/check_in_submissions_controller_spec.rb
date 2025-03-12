RSpec.describe(Api::CheckInSubmissionsController) do
  let(:check_in) { CheckIn.first! }
  let(:user) { check_in.marriage.partners.first! }

  before { sign_in(user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: { check_in_id: check_in.id }) }

    context 'when the user has already submitted their check-in' do
      before { create(:check_in_submission, user:, check_in:) }

      it 'returns an empty 204 response' do
        post_create
        expect(response.body).to eq('')
        expect(response).to have_http_status(204)
      end
    end

    context 'when the user has not filled out all of the ratings' do
      before do
        user.need_satisfaction_ratings.where(check_in:).find_each(&:destroy!)
      end

      it 'returns a 422 status code' do
        post_create
        expect(response).to have_http_status(422)
      end
    end

    context 'when the user has filled out all of the ratings' do
      before do
        user.need_satisfaction_ratings.where(check_in:).find_each do |rating|
          rating.update!(score: rand(-3..3))
        end
      end

      it 'creates a CheckInSubmission' do
        expect { post_create }.to change { CheckInSubmission.count }.by(1)
      end
    end
  end
end
