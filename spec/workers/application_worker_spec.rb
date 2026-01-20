RSpec.describe ApplicationWorker do
  before do
    stub_const('StubbedTestJob', Class.new)

    StubbedTestJob.class_eval do
      prepend ApplicationWorker

      class << self
        attr_accessor :perform_was_called
      end

      self.perform_was_called = false

      def perform
        self.class.perform_was_called = true
      end
    end
  end

  let(:worker) { StubbedTestJob.new }

  describe '#perform' do
    subject(:call_perform) { worker.perform }

    context 'when the job is disabled via a flipper flag' do
      before { activate_feature!(:disable_stubbed_test_job_worker) }

      it "does not execute the worker's perform method" do
        call_perform
        expect(StubbedTestJob.perform_was_called).to eq(false)
      end
    end

    context 'when the job is not disabled via a flipper flag' do
      before { expect(Flipper.enabled?(:disable_stubbed_test_job_worker)).to be(false) }

      it "executes the worker's perform method" do
        call_perform
        expect(StubbedTestJob.perform_was_called).to eq(true)
      end
    end

    context 'when the worker sets unique_while_executing to true' do
      before do
        StubbedTestJob.class_eval do
          unique_while_executing!
        end
      end

      it "executes the worker's perform method" do
        call_perform
        expect(StubbedTestJob.perform_was_called).to eq(true)
      end

      context 'when a lock for that job + arguments is already in redis' do
        # Checking #lock_obtained? sets the lock (if it's not already set):
        before do
          if worker.send(:lock_obtained?, []) != 'OK'
            Sidekiq.redis do |conn|
              remaining_milliseconds = conn.call('pttl', worker.send(:lock_key, []))
              fail "#{remaining_milliseconds} milliseconds are still on lock"
            end
          end
        end

        it "does not execute the worker's perform method" do
          call_perform
          expect(StubbedTestJob.perform_was_called).to eq(false)
        end
      end
    end
  end
end
