# frozen_string_literal: true

RSpec.describe InvalidRecordsCheck::Launcher do
  subject(:worker) { InvalidRecordsCheck::Launcher.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when the application has been eager loaded' do
      before { Rails.application.eager_load! }

      it 'enqueues `InvalidRecordsCheck::Checker` jobs' do
        expect {
          perform
        }.to change {
          Sidekiq::Queues['default'].size
        }.by(ApplicationRecord.descendants.reject { _1.descendants.any? }.size)
      end
    end
  end
end
