module MockOmniAuth
  def self.google_oauth2(email:, sub: "1#{rand(100_000_000_000_000_000)}")
    OmniAuth.config.add_mock(
      :google_oauth2,
      provider: 'google_oauth2',
      uid: '12345678910',
      info: {
        email:,
      },
      credentials: {
        token: 'abcdefg12345',
        expires_at: 1.hour.from_now,
        expires: true,
      },
      extra: {
        id_info: {
          sub:,
        },
      },
    )
  end
end
