RSpec.describe ContentSignature do
  let(:private_key) { OpenSSL::PKey.generate_key('ED25519') }
  let(:signed_object_key) { 'prerenders/a-git-revision/home.html' }
  let(:signed_content) { '<html>Home</html>' }
  let(:object_key) { signed_object_key }
  let(:content) { signed_content }
  let(:public_key) { OpenSSL::PKey.read(private_key.public_to_pem) }

  describe '.verify!' do
    subject(:verify_signature) do
      described_class.verify!(
        content:,
        object_key:,
        signature:,
        public_key:,
      )
    end

    let(:signature) do
      described_class.signature(
        content: signed_content,
        object_key: signed_object_key,
        private_key:,
      )
    end

    it 'accepts a signature for the artifact content and object key' do
      expect { verify_signature }.not_to raise_error
    end

    context 'when the artifact content has changed' do
      let(:content) { '<html>Changed</html>' }

      it 'rejects the signature' do
        expect { verify_signature }.
          to raise_error(described_class::InvalidSignatureError, /Invalid signature/)
      end
    end

    context 'when the artifact object key has changed' do
      let(:object_key) { 'prerenders/a-different-git-revision/home.html' }

      it 'rejects the signature' do
        expect { verify_signature }.
          to raise_error(described_class::InvalidSignatureError, /Invalid signature/)
      end
    end
  end
end
