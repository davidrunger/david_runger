class CiStepResultsPresenter
  prepend Memoization

  FIELDS_TO_PLUCK = %i[name github_run_id github_run_attempt created_at seconds].freeze

  def initialize(user)
    @user = user
  end

  memoize \
  def parallelism
    wall_clock_times = run_times_by_step.detect { it[:name] == 'WallClockTime' }[:data]
    cpu_times = run_times_by_step.detect { it[:name] == 'CpuTime' }[:data]

    wall_clock_times.each.filter_map do |time, wall_clock_time|
      if (cpu_time = cpu_times[time])
        [time, cpu_time.fdiv(wall_clock_time)]
      end
    end.to_h
  end

  memoize \
  def run_times_by_step
    results_grouped_by_name.map do |name, rows|
      {
        name:,
        data:
          rows.to_h do |_name, github_run_id, github_run_attempt, _created_at, seconds|
            # Lines will only appear if each series has dots at the exact same
            # time, so we will standardize on the earliest created_at.
            # https://github.com/ankane/chartkick/issues/ 137#issuecomment-58734647
            [earliest_created_at(github_run_id:, github_run_attempt:), seconds]
          end,
      }
    end
  end

  private

  memoize \
  def ci_step_results_row_data
    @user.
      ci_step_results.
      pluck(*FIELDS_TO_PLUCK)
  end

  def results_grouped_by_name
    name_index = FIELDS_TO_PLUCK.index(:name)

    ci_step_results_row_data.group_by { |row| row[name_index] }
  end

  def earliest_created_at(github_run_id:, github_run_attempt:)
    results_grouped_by_run_id_and_attempt[[github_run_id, github_run_attempt]].
      pluck(FIELDS_TO_PLUCK.index(:created_at)).
      min
  end

  memoize \
  def results_grouped_by_run_id_and_attempt
    ci_step_results_row_data.
      group_by do |_name, github_run_id, github_run_attempt, _created_at, _seconds|
        [github_run_id, github_run_attempt]
      end
  end
end
