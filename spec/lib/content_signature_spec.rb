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

    context 'when the signature is not valid Base64' do
      let(:signature) { 'not valid Base64' }

      it 'raises an error about the signature encoding' do
        expect { verify_signature }.
          to raise_error(described_class::InvalidSignatureError, /Invalid signature encoding/)
      end
    end
  end

  describe '.key_from_base64' do
    subject(:key_from_base64) { described_class.key_from_base64(encoded_key) }

    context 'when the value is not valid Base64' do
      let(:encoded_key) { 'not valid Base64' }

      it 'raises an error about the signing key' do
        expect { key_from_base64 }.
          to raise_error(described_class::InvalidSignatureError, /Invalid signing key/)
      end
    end

    context 'when the decoded value is not a PEM key' do
      let(:encoded_key) { Base64.strict_encode64('not a PEM key') }

      it 'raises an error about the signing key' do
        expect { key_from_base64 }.
          to raise_error(described_class::InvalidSignatureError, /Invalid signing key/)
      end
    end
  end
end
