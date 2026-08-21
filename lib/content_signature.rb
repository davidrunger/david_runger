class ContentSignature
  class InvalidSignatureError < StandardError; end

  class << self
    def signature(content:, object_key:, private_key:)
      Base64.strict_encode64(private_key.sign(nil, signing_payload(content:, object_key:)))
    end

    def verify!(content:, object_key:, signature:, public_key:)
      valid_signature =
        public_key.verify(
          nil,
          Base64.strict_decode64(signature),
          signing_payload(content:, object_key:),
        )

      unless valid_signature
        raise(InvalidSignatureError, "Invalid signature for #{object_key}.")
      end
    rescue ArgumentError
      raise(InvalidSignatureError, "Invalid signature encoding for #{object_key}.")
    end

    def key_from_base64(encoded_key)
      OpenSSL::PKey.read(Base64.strict_decode64(encoded_key))
    rescue ArgumentError, OpenSSL::PKey::PKeyError => error
      raise(InvalidSignatureError, "Invalid signing key: #{error.message}")
    end

    private

    def signing_payload(content:, object_key:)
      "#{object_key}\0#{content}"
    end
  end
end
