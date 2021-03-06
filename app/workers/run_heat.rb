# frozen_string_literal: true

require 'aws-sdk-s3'

class RunHeat
  prepend ApplicationWorker

  IMAGES_DIRECTORY = 'tmp/heat/images/'

  sidekiq_options(retry: 2)

  def perform
    # download
    system('bin/heat -n 32', exception: true)

    return if Dir.empty?(IMAGES_DIRECTORY)

    # zip
    zip_file_name = "#{Time.current.iso8601.tr(':', '-')}.zip"
    system(<<~COMMANDS.squish, exception: true)
      cd #{IMAGES_DIRECTORY} &&
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
