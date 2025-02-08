RSpec.describe(Api::CiStepResultsController) do
  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    context 'when no current_user is present' do
      before { controller.sign_out_all_scopes }

      let(:params) { ci_step_result_params }
      let(:ci_step_result_params) { valid_ci_step_result_params }
      let(:valid_ci_step_result_params) do
        {
          ci_step_result: {
            name: 'RunUnitTests',
            seconds: 18.984,
            started_at: 1.minute.ago,
            stopped_at: 10.seconds.ago,
            passed: true,
            github_run_id: 13_578_642,
            github_run_attempt: 1,
            branch: 'main',
            sha: SecureRandom.hex(20),
          },
        }
      end

      context 'when no auth_token param is provided' do
        before { expect(params[:auth_token]).to eq(nil) }

        it 'does not create a CiStepResult and responds with a 401 status code and error message' do
          expect { post_create }.not_to change { CiStepResult.count }
          expect(response).to have_http_status(401)
          expect(response.parsed_body).to eq('error' => 'Your request was not authenticated')
        end
      end

      context 'when a valid auth_token param is provided' do
        let(:user) { User.joins(:auth_tokens).first! }
        let(:params) do
          ci_step_result_params.merge(auth_token: user.auth_tokens.first!.secret)
        end

        context 'when the CiStepResult params are valid' do
          let(:ci_step_result_params) { valid_ci_step_result_params }

          it 'creates a CiStepResult for the user and returns a 201 status code' do
            expect { post_create }.to change { user.reload.ci_step_results.size }.by(1)
            expect(response).to have_http_status(201)
          end
        end

        context 'when the CiStepResult params are invalid' do
          let(:ci_step_result_params) do
            valid_ci_step_result_params.deep_merge({
              ci_step_result: {
                name: nil,
              },
            })
          end

          it 'returns a 422 status code' do
            post_create

            expect(response).to have_http_status(422)
            expect(response.parsed_body).to eq({ 'errors' => { 'name' => ["can't be blank"] } })
          end
        end
      end
    end
  end
end
