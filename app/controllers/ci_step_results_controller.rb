class CiStepResultsController < ApplicationController
  prepend Memoization

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
        ransack(search_params_with_defaults)
    @ci_step_results_presenter =
      CiStepResultsPresenter.new(
        ci_step_results: @ransack_query.result,
        user: current_user,
        search_params: search_params_with_defaults,
      )

    bootstrap(
      recent_gantt_chart_metadatas:
        @ci_step_results_presenter.recent_gantt_chart_metadatas,
    )

    render :index
  end

  private

  memoize \
  def search_params_with_defaults
    default_index_filters.merge(search_params[:q] || {})
  end

  def search_params
    params.permit(q: %i[branch_eq created_at_gt name_eq passed_eq])
  end

  def default_index_filters
    {
      'branch_eq' => 'main',
      'created_at_gt' => 2.months.ago,
      'passed_eq' => true,
    }
  end
end
