RSpec.describe(Api::CiStepResults::BulkCreationsController) do
  describe '#create' do
    subject(:post_create) { post(:create, params:) }

    let(:params) { ci_step_results_params }
    let(:ci_step_results_params) { { ci_step_results: ci_step_results_data } }
    let(:ci_step_results_data) { valid_ci_step_results_data }
    let(:valid_ci_step_results_data) { [valid_ci_step_result_1, valid_ci_step_result_2] }
    let(:valid_ci_step_result_1) do
      common_ci_step_result_data.merge({
        name: 'RunUnitTests',
        seconds: 18.984,
        started_at: 1.minute.ago,
        stopped_at: 10.seconds.ago,
      })
    end
    let(:valid_ci_step_result_2) do
      common_ci_step_result_data.merge({
        name: 'RunFeatureTests',
        seconds: 80.592,
        started_at: 2.minutes.ago,
        stopped_at: 20.seconds.ago,
      })
    end
    let(:valid_ci_step_result_3) do
      common_ci_step_result_data.merge({
        name: 'RunLinters',
        seconds: 5.432,
        started_at: 3.minutes.ago,
        stopped_at: 30.seconds.ago,
      })
    end
    let(:common_ci_step_result_data) do
      attributes_for(:ci_step_result).slice(*%i[
        passed
        github_run_id
        github_run_attempt
        branch
        sha
      ])
    end

    specify 'a request can contain at most 200 CI step results' do
      expect(CiStepResults::BulkCreate::MAX_CI_STEP_RESULTS).to eq(200)
    end

    context 'when no user is signed in' do
      before { controller.sign_out_all_scopes }

      context 'when no auth_token param is provided' do
        before { expect(params[:auth_token]).to eq(nil) }

        it 'does not create any CiStepResults and responds with a 401 status code and error message' do
          expect { post_create }.not_to change { CiStepResult.count }

          expect(response).to have_http_status(401)
          expect(response.parsed_body).to eq('error' => 'Your request was not authenticated')
        end
      end

      context 'when a valid auth_token param is provided' do
        let(:user) { User.joins(:auth_tokens).first! }
        let(:params) { super().merge(auth_token: user.auth_tokens.first!.secret) }

        context 'when the CiStepResult params are valid' do
          let(:ci_step_results_data) { valid_ci_step_results_data }

          it 'creates CiStepResults for the user and returns a 201 status code' do
            expect { post_create }.to change {
              user.reload.ci_step_results.size
            }.by(ci_step_results_data.size.tap do |size|
              expect(size).to be >= 2
            end)

            expect(response).to have_http_status(201)
          end

          context 'when another user has a result for the same GitHub run' do
            before do
              create(
                :ci_step_result,
                user: User.excluding(user).first!,
                **valid_ci_step_result_1.slice(:name, :github_run_id, :github_run_attempt),
              )
            end

            it 'creates CiStepResults for the authenticated user' do
              expect { post_create }.to change {
                user.reload.ci_step_results.size
              }.by(ci_step_results_data.size)

              expect(response).to have_http_status(201)
            end
          end
        end

        context 'when the CiStepResult params are invalid' do
          let(:ci_step_results_data) do
            [valid_ci_step_result_1, invalid_ci_step_result, valid_ci_step_result_3]
          end
          let(:invalid_ci_step_result) do
            valid_ci_step_result_2.merge({
              branch: '',
            })
          end

          it 'does not create any CiStepResults and returns a 422 status code' do
            expect { post_create }.not_to change { CiStepResult.count }

            expect(response).to have_http_status(422)
            expect(response.parsed_body).to eq(JSON.parse([
              {
                success: true,
                errors: {},
                data: valid_ci_step_result_1,
              },
              {
                success: false,
                errors: { branch: ["can't be blank"] },
                data: invalid_ci_step_result,
              },
              {
                success: true,
                errors: {},
                data: valid_ci_step_result_3,
              },
            ].to_json))
          end
        end

        context 'when the request contains too many CiStepResults' do
          before { stub_const('CiStepResults::BulkCreate::MAX_CI_STEP_RESULTS', 2) }

          let(:ci_step_results_data) do
            [valid_ci_step_result_1, valid_ci_step_result_2, valid_ci_step_result_3]
          end

          it 'does not create any CiStepResults and returns a 422 status code' do
            expect(ApplicationRecord).not_to receive(:transaction)
            expect { post_create }.not_to change { CiStepResult.count }

            expect(response).to have_http_status(422)
            expect(response.parsed_body).to eq([
              {
                'success' => false,
                'errors' => {
                  'base' => ['Requests may contain no more than 2 CI step results.'],
                },
                'data' => {},
              },
            ])
          end
        end
      end
    end
  end
end
