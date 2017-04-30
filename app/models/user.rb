class User < ApplicationRecord
  devise :registerable, :rememberable, :trackable,
    :omniauthable, omniauth_providers: [:google_oauth2]
end
