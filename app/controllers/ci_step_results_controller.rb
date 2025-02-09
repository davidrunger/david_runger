class CiStepResultsController < ApplicationController
  self.container_classes = %w[p-8]

  def index
    authorize(CiStepResult)

    @title = 'CI Timings'
    @ci_step_results_presenter = CiStepResultsPresenter.new(current_user)

    render :index
  end
end
