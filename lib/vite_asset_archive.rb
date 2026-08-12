module ViteAssetArchive
  SIGNATURE_METADATA_KEY = 'vite-asset-signature'

  class << self
    def object_key(git_sha:, directory_name:)
      "compiled-assets/#{git_sha}/#{directory_name}.zip"
    end

    def upload(bucket:, git_sha:, directory_name:, content:, private_key:)
      object_key = object_key(git_sha:, directory_name:)

      bucket.object(object_key).put(
        body: content,
        metadata: {
          SIGNATURE_METADATA_KEY =>
            ContentSignature.signature(
              content:,
              object_key:,
              private_key:,
            ),
        },
      )
    end

    def download(bucket:, git_sha:, directory_name:, response_target:, public_key:)
      object_key = object_key(git_sha:, directory_name:)
      get_response = bucket.object(object_key).get(response_target:)

      ContentSignature.verify!(
        content: File.binread(response_target),
        object_key:,
        signature: get_response.metadata.fetch(SIGNATURE_METADATA_KEY),
        public_key:,
      )
    end
  end
end
