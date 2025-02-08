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

        it 'responds with 200 and a chartkick line graph' do
          get(:index)

          expect(response).to have_http_status(200)
          expect(response.body).to have_text('new Chartkick["LineChart"]')
        end
      end
    end
  end
end
