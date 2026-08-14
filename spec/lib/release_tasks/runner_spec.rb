RSpec.describe ReleaseTasks::Runner do
  subject(:runner) { described_class.new }

  describe '#run_task' do
    it 'runs the block and reports its duration' do
      allow(Time).to receive(:current).and_return(Time.zone.at(0), Time.zone.at(1.234))
      block_ran = false

      expect do
        runner.run_task('Doing something') { block_ran = true }
      end.to output("Doing something... done. (Took 1.23 seconds.)\n").to_stdout

      expect(block_ran).to be(true)
    end
  end

  describe '#run_rake_task_with_retries' do
    subject(:run_rake_task_with_retries) do
      runner.run_rake_task_with_retries(task_name, attempts:)
    end

    let(:attempts) { 3 }
    let(:task_name) { "spec:retryable_task_#{SecureRandom.hex}" }
    let(:task) { Rake::Task.define_task(task_name) { task_action.call } }
    let(:task_action) { instance_double(Proc) }

    before do
      task
      allow(runner).to receive(:pp)
      allow(runner).to receive(:sleep)
    end

    context 'when the task succeeds on its first attempt' do
      before do
        allow(task_action).to receive(:call)
      end

      it 'invokes the task once without sleeping' do
        run_rake_task_with_retries

        expect(task_action).to have_received(:call).once
        expect(runner).not_to have_received(:sleep)
      end
    end

    context 'when the task succeeds after an initial failure' do
      before do
        allow(task_action).to receive(:call).and_invoke(
          -> { raise('transient failure') },
          -> {},
        )
      end

      it 're-enables and invokes the task again' do
        run_rake_task_with_retries

        expect(task_action).to have_received(:call).twice
        expect(runner).to have_received(:sleep).once.with(1)
      end
    end

    context 'when every attempt fails' do
      let(:final_error) { RuntimeError.new('persistent failure') }

      before do
        allow(task_action).to receive(:call).and_raise(final_error)
      end

      it 'raises the final error after invoking the task for every attempt' do
        expect { run_rake_task_with_retries }.to raise_error(final_error)

        expect(task_action).to have_received(:call).exactly(attempts).times
      end

      it 'sleeps only between attempts' do
        expect { run_rake_task_with_retries }.to raise_error(final_error)

        expect(runner).to have_received(:sleep).ordered.with(1)
        expect(runner).to have_received(:sleep).ordered.with(2)
      end
    end
  end

  describe '#with_modified_env' do
    it 'restores existing and absent environment variables when the block raises' do
      ClimateControl.modify(
        'EXISTING_RELEASE_TASKS_SPEC_VAR' => 'original',
        'ABSENT_RELEASE_TASKS_SPEC_VAR' => nil,
      ) do
        expect do
          runner.with_modified_env(
            'EXISTING_RELEASE_TASKS_SPEC_VAR' => 'modified',
            'ABSENT_RELEASE_TASKS_SPEC_VAR' => 'added',
          ) do
            expect(ENV.fetch('EXISTING_RELEASE_TASKS_SPEC_VAR')).to eq('modified')
            expect(ENV.fetch('ABSENT_RELEASE_TASKS_SPEC_VAR')).to eq('added')
            raise('block failure')
          end
        end.to raise_error('block failure')

        expect(ENV.fetch('EXISTING_RELEASE_TASKS_SPEC_VAR')).to eq('original')
        expect(ENV.fetch('ABSENT_RELEASE_TASKS_SPEC_VAR', nil)).to be_nil
      end
    end
  end
end
