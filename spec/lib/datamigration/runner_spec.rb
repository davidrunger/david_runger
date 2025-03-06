RSpec.describe Datamigration::Runner do
  subject(:runner) { Datamigration::Runner.new(StubbedDatamigration) }

  before do
    stub_const('StubbedDatamigration', Class.new(Datamigration::Base))

    StubbedDatamigration.class_eval do
      def run
        within_transaction do
          new_email = "#{SecureRandom.uuid}@davidrunger.com"
          log("Updating a user's email to #{new_email} .")
          User.first.update!(email: new_email)
        end
      end
    end
  end

  describe '#run' do
    subject(:run) { runner.run }

    it 'creates a DatamigrationRun record' do
      expect { run }.to change { DatamigrationRun.count }.by(1)

      datamigration_run = DatamigrationRun.reorder(:created_at).last!
      expect(datamigration_run.name).to eq(StubbedDatamigration.name)
      expect(datamigration_run.developer).to be_present
      expect(datamigration_run.completed_at).to be_a(Time)
    end

    it 'sends an email' do
      with_inline_sidekiq do
        expect { run }.to change { ActionMailer::Base.deliveries.size }.by(1)

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq(['davidjrunger@gmail.com'])
        expect(mail.subject).to eq('A(n) StubbedDatamigration datamigration has been started')

        datamigration_run = DatamigrationRun.reorder(:created_at).last!
        body = Capybara.string(mail.body.to_s)
        expect(body).to have_link(
          datamigration_run.class_id_string,
          href: Rails.application.routes.url_helpers.admin_datamigration_run_url(datamigration_run),
        )
      end
    end
  end

  describe '#logging_start_and_finish' do
    context 'when Rails.logger.level is :info' do
      around do |spec|
        Rails.logger.with(level: :info) do
          spec.run
        end
      end

      let(:logdev) do
        runner.instance_variable_get(:@datamigration_instance).send(:logger).broadcasts.first.instance_variable_get(:@logdev)
      end

      before do
        if logdev
          allow(logdev).to receive(:write).and_call_original
        end
      end

      it 'logs start and finish messages around the given block' do
        result = nil

        runner.send(:logging_start_and_finish) do
          result = 'block executed'
        end

        expect(logdev).to have_received(:write).ordered.with(
          /\[StubbedDatamigration\] Starting at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\.\.\./,
        )
        # rubocop:disable Layout/LineLength
        expect(logdev).to have_received(:write).ordered.with(
          /\[StubbedDatamigration\] Finished at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\. Took \d+\.\d+ seconds\./,
        )
        # rubocop:enable Layout/LineLength
        expect(result).to eq('block executed')
      end

      it 'logs starting message and propagates any exceptions that occur' do
        expect do
          runner.send(:logging_start_and_finish) do
            raise('test error')
          end
        end.to raise_error('test error')

        expect(logdev).to have_received(:write).exactly(:once)
        expect(logdev).to have_received(:write).with(
          /\[StubbedDatamigration\] Starting at \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\.\.\./,
        )
      end
    end
  end
end
