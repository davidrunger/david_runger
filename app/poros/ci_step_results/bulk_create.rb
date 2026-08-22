class CiStepResults::BulkCreate
  MAX_CI_STEP_RESULTS = 200

  def initialize(user:, ci_step_results_data:)
    @user = user
    @ci_step_results_data = ci_step_results_data
    @validation_results = []
  end

  def perform
    if @ci_step_results_data.size > MAX_CI_STEP_RESULTS
      [
        :error,
        [
          {
            success: false,
            errors: {
              base: ["Requests may contain no more than #{MAX_CI_STEP_RESULTS} CI step results."],
            },
            data: {},
          },
        ],
      ]
    else
      at_least_one_invalid_record = false

      ApplicationRecord.transaction do
        @ci_step_results_data.each do |ci_step_result_data|
          new_ci_step_result = @user.ci_step_results.build(ci_step_result_data)

          # Don't waste time trying to save records if we know some are already invalid.
          # rubocop:disable Rails/SaveBang
          if at_least_one_invalid_record ? new_ci_step_result.valid? : new_ci_step_result.save
            # rubocop:enable Rails/SaveBang
            @validation_results << {
              success: true,
              errors: {},
              data: ci_step_result_data,
            }
          else
            at_least_one_invalid_record = true

            @validation_results << {
              success: false,
              errors: new_ci_step_result.errors.to_hash,
              data: ci_step_result_data,
            }
          end
        end

        if at_least_one_invalid_record
          raise(ActiveRecord::Rollback)
        end
      end

      [
        at_least_one_invalid_record ? :error : :ok,
        @validation_results,
      ]
    end
  end
end
