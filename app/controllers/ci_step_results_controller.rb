class CiStepResultsController < ApplicationController
  self.container_classes = %w[p-8]

  def index
    authorize(CiStepResult)

    @title = 'CI Timings'
    @chart_data = CiStepResultsPresenter.new(current_user).data

    render :index
  end
end
