class Api::CiStepResultsController < Api::BaseController
  def create
    authorize(CiStepResult)

    @ci_step_result =
      current_or_auth_token_user.
        ci_step_results.
        build(ci_step_result_params)

    if @ci_step_result.save
      head :created
    else
      render json: { errors: @ci_step_result.errors.to_hash }, status: :unprocessable_entity
    end
  end

  private

  def ci_step_result_params
    params.expect(ci_step_result: %i[
      name
      seconds
      started_at
      stopped_at
      passed
      github_run_id
      github_run_attempt
      branch
      sha
    ])
  end
end
