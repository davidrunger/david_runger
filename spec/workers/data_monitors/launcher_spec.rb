# frozen_string_literal: true

RSpec.describe DataMonitors::Launcher do
  subject(:worker) { DataMonitors::Launcher.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when the application has been eager loaded' do
      before { Rails.application.eager_load! }

      it 'schedules a job on the default queue for each descendant of `DataMonitors::Base`' do
        expect(DataMonitors::Base.descendants.size).to be >= 2

        expect {
          perform
        }.to change {
          Sidekiq::Queues['default'].size
        }.by(DataMonitors::Base.descendants.size)
      end
    end
  end
end
