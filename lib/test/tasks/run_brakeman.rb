class Test::Tasks::RunBrakeman < Pallets::Task
  include Test::TaskHelpers

  def run
    files_to_skip =
      ['app/workers/application_worker.rb'] +
      `git status --ignored --porcelain | cut -d' ' -f 2 | grep 'config/initializers/'`.
        split("\n")
    skip_files_arg =
      files_to_skip.map do |file_to_skip|
        "--skip-files #{file_to_skip}"
      end.join(' ')

    # skip `application_worker.rb` because it has `...`, which the brakeman parser cannot understand
    execute_system_command(<<~COMMAND.squish, log_stdout_only_on_failure: true)
      bin/brakeman
        --quiet
        --no-pager
        #{skip_files_arg}
    COMMAND
  end
end
