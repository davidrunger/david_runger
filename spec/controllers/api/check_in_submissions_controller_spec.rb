# frozen_string_literal: true

RSpec.describe(Api::CheckInSubmissionsController) do
  let(:check_in) { CheckIn.first! }
  let(:user) { check_in.marriage.partner_1 }

  before { sign_in(user) }

  describe '#create' do
    subject(:post_create) { post(:create, params: { check_in_id: check_in.id }) }

    context 'when the user has not filled out all of the ratings' do
      before do
        user.need_satisfaction_ratings.where(check_in:).find_each(&:destroy!)
      end

      it 'returns a 422 status code' do
        post_create
        expect(response).to have_http_status(422)
      end
    end
  end
end
