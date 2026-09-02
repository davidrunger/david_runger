class CiStepResultsController < ApplicationController
  prepend Memoization

  self.container_classes = %w[p-8]

  def index
    authorize(CiStepResult)

    @title = 'CI Timings'
    @ransack_query =
      current_user.
        ci_step_results.
        ransack(search_params_with_defaults)
    @ci_step_results_form_presenter =
      CiStepResultsFormPresenter.new(
        user: current_user,
        search_params: search_params_with_defaults,
      )
    @gantt_chart_limit = gantt_chart_limit
    @ci_step_results_presenter =
      CiStepResultsPresenter.new(
        ci_step_results: @ransack_query.result,
        gantt_chart_limit: @gantt_chart_limit,
        gantt_chart_ci_step_results:
          current_user.
            ci_step_results.
            ransack(search_params_with_defaults.except('name_eq', 'passed_eq')).
            result,
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
    default_index_filters.merge(search_params[:q]&.except(:gantt_chart_limit) || {})
  end

  memoize \
  def gantt_chart_limit
    requested_limit = Integer(search_params.dig(:q, :gantt_chart_limit), exception: false)

    if requested_limit&.positive?
      requested_limit.clamp(1, CiStepResultsPresenter::MAX_GANTT_CHART_LIMIT)
    else
      CiStepResultsPresenter::DEFAULT_GANTT_CHART_LIMIT
    end
  end

  def search_params
    params.permit(q: %i[
      branch_eq
      created_at_gt
      gantt_chart_limit
      name_eq
      passed_eq
    ])
  end

  def default_index_filters
    {
      'branch_eq' => 'main',
      'created_at_gt' => 2.months.ago,
      'passed_eq' => true,
    }
  end
end
