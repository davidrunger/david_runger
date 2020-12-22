# frozen_string_literal: true

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

  describe '#perform' do
    subject(:call_perform) { StubbedTestJob.new.perform }

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
  end
end
