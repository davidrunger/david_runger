class CiStepResultsFormPresenter
  prepend Memoization

  def initialize(user:, search_params:)
    @user = user
    @search_params = search_params
  end

  memoize \
  def branch_names
    user_ci_step_results_in_time_range.
      distinct.
      pluck(:branch).
      sort_by do |branch_name|
        if branch_name == 'main'
          ''
        else
          branch_name.downcase
        end
      end
  end

  memoize \
  def ci_step_names
    user_ci_step_results_in_time_range.
      distinct.
      pluck(:name).
      sort_by(&:downcase)
  end

  private

  memoize \
  def user_ci_step_results_in_time_range
    @user.
      ci_step_results.
      where(created_at: @search_params.fetch('created_at_gt')..)
  end
end
