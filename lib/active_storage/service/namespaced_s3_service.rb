# frozen_string_literal: true

# Modified w/ gratitude <3 from https://github.com/rails/rails/issues/ 32790#issuecomment-487523740

require 'active_storage/service/s3_service'

class ActiveStorage::Service::NamespacedS3Service < ActiveStorage::Service::S3Service
  def initialize(bucket:, upload: {}, public: false, **options)
    @namespace = options.delete(:namespace).presence!
    super
  end

  private

  def object_for(key)
    bucket.object(File.join(@namespace, key))
  end
end
