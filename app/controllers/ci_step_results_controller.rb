class CiStepResultsController < ApplicationController
  self.container_classes = %w[p-8]

  content_security_policy(only: :index) do |policy|
    # 'unsafe-eval' is needed by vega (which renders Gantt charts of the run times).
    policy.script_src(:self, :unsafe_eval)
  end

  def index
    authorize(CiStepResult)

    @title = 'CI Timings'
    @ci_step_results_presenter = CiStepResultsPresenter.new(current_user)

    bootstrap(
      recent_gantt_chart_metadatas:
        @ci_step_results_presenter.recent_gantt_chart_metadatas,
    )

    render :index
  end
end
