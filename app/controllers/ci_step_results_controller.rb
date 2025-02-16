class CiStepResultsController < ApplicationController
  self.container_classes = %w[p-8]

  content_security_policy(only: :index) do |policy|
    # 'unsafe-eval' is needed by vega (which renders Gantt charts of the run times).
    policy.script_src(:self, :unsafe_eval)
  end

  def index
    authorize(CiStepResult)

    @title = 'CI Timings'
    @ransack_query =
      current_user.
        ci_step_results.
        ransack(
          default_index_filters.
            merge(search_params[:q] || {}),
        )
    @ci_step_results_presenter = CiStepResultsPresenter.new(@ransack_query.result)

    bootstrap(
      recent_gantt_chart_metadatas:
        @ci_step_results_presenter.recent_gantt_chart_metadatas,
    )

    render :index
  end

  private

  def search_params
    params.permit(q: %i[branch_eq passed_eq created_at_gt])
  end

  def default_index_filters
    {
      'branch_eq' => 'main',
      'passed_eq' => true,
      'created_at_gt' => 2.months.ago,
    }
  end
end
