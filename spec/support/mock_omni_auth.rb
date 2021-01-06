# frozen_string_literal: true

module MockOmniAuth
  def self.google_oauth2(email:)
    OmniAuth.config.add_mock(
      :google_oauth2,
      provider: 'google_oauth2',
      uid: '12345678910',
      info: {
        email: email,
      },
      credentials: {
        token: 'abcdefg12345',
        expires_at: 1.hour.from_now,
        expires: true,
      },
    )
  end
end
