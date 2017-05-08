class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :requests
  has_many :stores
  has_many :items, through: :stores
  has_many :templates

  def self.from_omniauth!(access_token)
    data = access_token.info
    user = User.find_or_create_by!(email: data['email'])
  end
end
