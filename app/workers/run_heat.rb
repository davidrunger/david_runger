# frozen_string_literal: true

require 'aws-sdk-s3'

class RunHeat
  include Sidekiq::Worker

  sidekiq_options(retry: 2)

  def perform
    if Flipper.enabled?(:disable_run_heat_worker)
      puts('Skipping RunHeat job because the `disable_run_heat_worker` flag is enabled.')
      return
    end

    # download
    system('bin/heat')

    # zip
    zip_file_name = "#{Time.current.iso8601.tr(':', '-')}.zip"
    system(<<~COMMANDS.squish)
      cd tmp/heat/images/ &&
        zip -r #{zip_file_name} ./ &&
        mv #{zip_file_name} ../ &&
        cd .. &&
        rm -rf ./images/
    COMMANDS

    # upload
    absolute_zip_path = Rails.root.join("tmp/heat/#{zip_file_name}").to_s
    s3 = Aws::S3::Resource.new(region: ENV['S3_REGION'])
    bucket = ENV['S3_BUCKET']
    s3_object = s3.bucket(bucket).object("heat/#{zip_file_name}")
    s3_object.upload_file(absolute_zip_path)
  end
end
