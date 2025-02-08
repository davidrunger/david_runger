class Api::CiStepResults::BulkCreationsController < Api::BaseController
  def create
    authorize(CiStepResult)

    case CiStepResults::BulkCreate.new(
      user: current_or_auth_token_user,
      ci_step_results_data: ci_step_results_bulk_create_params,
    ).perform
    in [:ok, _]
      head :created
    in [:error, validation_results]
      render json: validation_results, status: :unprocessable_entity
    end
  end

  private

  def ci_step_results_bulk_create_params
    params.expect(ci_step_results: [
      %i[
        name
        seconds
        started_at
        stopped_at
        passed
        github_run_id
        github_run_attempt
        branch
        sha
      ],
    ])
  end
end
