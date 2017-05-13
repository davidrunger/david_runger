# == Schema Information
#
# Table name: users
#
#  created_at       :datetime         not null
#  email            :string           not null
#  id               :integer          not null, primary key
#  last_activity_at :datetime
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :requests
  has_many :stores
  has_many :items, through: :stores
  has_many :templates

  def self.from_omniauth!(access_token)
    user = User.find_or_create_by!(email: access_token.info['email'])
  end
end
