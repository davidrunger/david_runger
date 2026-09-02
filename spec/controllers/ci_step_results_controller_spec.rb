RSpec.describe(CiStepResultsController) do
  describe '#index' do
    context 'when a user is signed in' do
      before { sign_in(user) }

      let(:user) { users(:user) }

      context 'when the user has some ci_step_results' do
        before { expect(user.ci_step_results.size).to be >= 2 }

        it 'responds with 200 and a chartkick line graph' do
          get(:index)

          expect(response).to have_http_status(200)
          expect(response.body).to have_text('new Chartkick["LineChart"]')
          expect(response.body).to have_field('Gantt charts', type: 'number', with: 10)
          expect(response.body).to have_css(
            'input[name="q[gantt_chart_limit]"][max="100"][min="1"]',
          )
        end

        context 'when a custom Gantt chart count is requested' do
          subject(:get_index) { get(:index, params: { q: { gantt_chart_limit: } }) }

          before do
            allow(CiStepResultsPresenter).to receive(:new).and_call_original
          end

          context 'when the Gantt chart count is within the allowed range' do
            let(:gantt_chart_limit) { 20 }

            before do
              expect(gantt_chart_limit).to be <= CiStepResultsPresenter::MAX_GANTT_CHART_LIMIT
            end

            it 'uses the requested count' do
              get_index

              expect(CiStepResultsPresenter).
                to have_received(:new).
                with(hash_including(gantt_chart_limit:))
              expect(response.body).to have_field(
                'Gantt charts',
                type: 'number',
                with: gantt_chart_limit,
              )
            end
          end

          context 'when the requested Gantt chart count exceeds the maximum' do
            let(:gantt_chart_limit) { 101 }

            before do
              expect(CiStepResultsPresenter::MAX_GANTT_CHART_LIMIT).to eq(100)
              expect(gantt_chart_limit).to eq(CiStepResultsPresenter::MAX_GANTT_CHART_LIMIT + 1)
            end

            it 'limits the count to 100' do
              get_index

              expect(CiStepResultsPresenter).
                to have_received(:new).
                with(hash_including(gantt_chart_limit: CiStepResultsPresenter::MAX_GANTT_CHART_LIMIT))
              expect(response.body).to have_field(
                'Gantt charts',
                type: 'number',
                with: CiStepResultsPresenter::MAX_GANTT_CHART_LIMIT,
              )
            end
          end
        end

        context 'when filtering by step name' do
          subject(:get_index) do
            get(:index, params: { q: { name_eq: 'RunFeatureTests' } })
          end

          it 'filters the line graph but includes every step in the Gantt charts' do
            get_index

            expect(
              assigns(:ci_step_results_presenter).run_times_by_step.pluck(:name),
            ).to eq(['RunFeatureTests'])
            expect(
              assigns(:bootstrap_data).
                fetch(:recent_gantt_chart_metadatas).
                flat_map { it.fetch(:run_times) }.
                pluck('name'),
            ).to contain_exactly(
              'CpuTime',
              'RunFeatureTests',
              'RunUnitTests',
              'WallClockTime',
            )
          end
        end
      end
    end
  end
end
