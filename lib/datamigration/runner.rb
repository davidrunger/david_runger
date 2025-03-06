class Datamigration::Runner
  def initialize(datamigration_class)
    @datamigration_instance = datamigration_class.new
  end

  def run
    create_datamigration_run_record!
    send_notification_email

    logging_start_and_finish do
      @datamigration_instance.run
    end

    @datamigration_run.update!(completed_at: @finish_time)
  end

  private

  def create_datamigration_run_record!
    @datamigration_run =
      DatamigrationRun.create!(
        developer: developer_email,
        name: @datamigration_instance.class.name,
      )
  end

  def developer_email
    case Rails.env
    in 'development' then `git config user.email`.rstrip
    in 'test' then 'developer@davidrunger.com'
    in 'production' then ENV.fetch('DEVELOPER_EMAIL')
    end
  end

  def send_notification_email
    AdminMailer.datamigration_run(@datamigration_run.id).deliver_later
  end

  def logging_start_and_finish
    start_time = Time.current.utc
    @datamigration_instance.log("Starting at #{start_time.iso8601}...")

    yield

    @finish_time = Time.current.utc
    @datamigration_instance.log(<<~LOG.squish)
      Finished at #{@finish_time.iso8601}.
      Took #{(@finish_time - start_time).round(2)} seconds.
    LOG
  end
end
