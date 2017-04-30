class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable,
    :omniauthable, omniauth_providers: [:google]
end
