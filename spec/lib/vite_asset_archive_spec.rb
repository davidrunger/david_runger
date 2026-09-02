require 'aws-sdk-s3'

RSpec.describe ViteAssetArchive do
  let(:private_key) { OpenSSL::PKey.generate_key('ED25519') }
  let(:public_key) { OpenSSL::PKey.read(private_key.public_to_pem) }
  let(:git_sha) { 'a-git-revision' }
  let(:directory_name) { 'vite' }
  let(:object_key) { "compiled-assets/#{git_sha}/#{directory_name}.zip" }
  let(:signed_content) { "PK\x03\x04archive content".b }
  let(:content) { signed_content }
  let(:object) { instance_double(Aws::S3::Object) }
  let(:bucket) { instance_double(Aws::S3::Bucket) }

  before do
    allow(bucket).to receive(:object).with(object_key).and_return(object)
  end

  describe '.upload' do
    it 'uploads a signature for the archive content and object key' do
      allow(object).to receive(:put) do |body:, metadata:|
        expect(body).to eq(content)
        expect(metadata).to include(described_class::SIGNATURE_METADATA_KEY)

        expect do
          ContentSignature.verify!(
            content: body,
            object_key:,
            signature: metadata.fetch(described_class::SIGNATURE_METADATA_KEY),
            public_key:,
          )
        end.not_to raise_error
      end

      described_class.upload(bucket:, git_sha:, directory_name:, content:, private_key:)

      expect(object).to have_received(:put).once
    end
  end

  describe '.download' do
    let(:response_target) { Rails.root.join('tmp/vite-asset-archive-spec.zip') }
    let(:signature) do
      ContentSignature.signature(content: signed_content, object_key:, private_key:)
    end
    let(:get_response) { instance_double(Aws::S3::Types::GetObjectOutput, metadata: { described_class::SIGNATURE_METADATA_KEY => signature }) }

    before do
      allow(object).to receive(:get).with(response_target:) do
        File.binwrite(response_target, content)
        get_response
      end
    end

    after { FileUtils.rm_f(response_target) }

    it 'accepts a signed archive' do
      expect do
        described_class.download(bucket:, git_sha:, directory_name:, response_target:, public_key:)
      end.not_to raise_error
    end

    context 'when the archive content has changed' do
      let(:content) { "PK\x03\x04modified archive content".b }

      it 'rejects the archive' do
        expect do
          described_class.download(
            bucket:,
            git_sha:,
            directory_name:,
            response_target:,
            public_key:,
          )
        end.to raise_error(ContentSignature::InvalidSignatureError, /Invalid signature/)
      end
    end
  end
end
