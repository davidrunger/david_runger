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
        expect(mail.subject).to eq('A StubbedDatamigration datamigration has been started')

        datamigration_run = DatamigrationRun.reorder(:created_at).last!
        body = Capybara.string(mail.body.to_s)
        expect(body).to have_link(
          datamigration_run.class_id_string,
          href: Rails.application.routes.url_helpers.admin_datamigration_run_url(datamigration_run),
        )
      end
    end
  end
end
