class CiStepResultsPresenter
  prepend Memoization

  FIELDS_TO_PLUCK = %i[name github_run_id github_run_attempt created_at seconds].freeze

  def initialize(ci_step_results:)
    @ci_step_results = ci_step_results
  end

  memoize \
  def parallelism
    wall_clock_times = run_times_by_step.detect { it[:name] == 'WallClockTime' }&.[](:data)
    cpu_times = run_times_by_step.detect { it[:name] == 'CpuTime' }&.[](:data)

    (wall_clock_times || []).each.filter_map do |time, wall_clock_time|
      if cpu_times && (cpu_time = cpu_times[time])
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

  memoize \
  def recent_gantt_chart_metadatas
    @ci_step_results.
      select(
        'MIN(ci_step_results.started_at) AS min_started_at',
        'ci_step_results.branch',
        'ci_step_results.github_run_id',
        'ci_step_results.github_run_attempt',
        <<-SQL.squish,
      JSON_AGG(
        JSON_BUILD_OBJECT(
          'name', ci_step_results.name,
          'started_at', ci_step_results.started_at,
          'stopped_at', ci_step_results.stopped_at,
          'seconds', ci_step_results.seconds
        ) ORDER BY ci_step_results.started_at
      ) AS run_times
    SQL
      ).
      group(:branch, :github_run_id, :github_run_attempt).
      order('min_started_at DESC').
      limit(10).
      map do |ci_step_result|
        github_run_attempt = ci_step_result.github_run_attempt
        github_run_id = ci_step_result.github_run_id

        {
          pretty_start_time:
            ci_step_result.min_started_at.in_time_zone.strftime('%b %d, %-l:%M %p'),
          branch: ci_step_result.branch,
          pretty_github_run_info:
            "Run #{github_run_id}, Attempt #{github_run_attempt}",
          github_run_id:,
          github_run_attempt:,
          dom_id:
            "gh-run-#{github_run_id}-#{github_run_attempt}",
          run_times:
            ci_step_result.run_times.map! do |run_time_hash|
              run_time_hash.to_h do |key, value|
                if key.end_with?('_at')
                  [key, "#{value}Z"]
                else
                  [key, value]
                end
              end
            end,
        }
      end
  end

  private

  memoize \
  def ci_step_results_row_data
    @ci_step_results.pluck(*FIELDS_TO_PLUCK)
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
