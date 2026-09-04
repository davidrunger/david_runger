class Test::Tasks::RunTypelizer < Pallets::Task
  include Test::TaskHelpers

  def run
    run_ruby_code(
      task_description: 'Generating TypeScript interfaces with Typelizer',
      on_failure: -> { record_failed_command('bin/run-test-steps RunTypelizer') },
    ) do
      ENV['DISABLE_TYPELIZER'] = 'false'
      serializers = Typelizer::Generator.call
      puts("Found #{serializers.size} serializers: #{serializers.map(&:name).join(' ')}")
    end

    execute_system_command(<<~'COMMAND')
      ! grep --quiet -RP '\bunknown\b' app/javascript/types/serializers/
    COMMAND

    if !execute_system_command('git diff --exit-code')
      # Reset the git state, so it's clean for other test tasks.
      execute_system_command('git checkout .')
    end
  end
end
