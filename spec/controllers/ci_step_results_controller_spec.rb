RSpec.describe(CiStepResultsController) do
  describe '#index' do
    context 'when a user is signed in' do
      before { sign_in(user) }

      context 'when the user has some ci_step_results' do
        before { expect(user.ci_step_results.size).to be >= 2 }

        let(:user) { users(:user) }

        it 'responds with 200 and a chartkick line graph' do
          get(:index)

          expect(response).to have_http_status(200)
          expect(response.body).to have_text('new Chartkick["LineChart"]')
        end
      end
    end
  end
end
