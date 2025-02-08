RSpec.describe(CiStepResultsController) do
  describe '#index' do
    context 'when a user is signed in' do
      before { sign_in(user) }

      context 'when the user has some ci_step_results' do
        let(:user) do
          User.
            joins(:ci_step_results).
            group(users: :id).
            having('COUNT(ci_step_results.id) >= 2').
            first!
        end

        it 'responds with 200' do
          get(:index)

          expect(response).to have_http_status(200)
        end
      end
    end
  end
end
