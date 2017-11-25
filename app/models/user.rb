# == Schema Information
#
# Table name: users
#
#  created_at       :datetime         not null
#  email            :string           not null
#  id               :integer          not null, primary key
#  last_activity_at :datetime
#  phone            :string
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  ADMIN_EMAILS = %w[davidjrunger@gmail.com].map(&:freeze).freeze

  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :requests
  has_many :stores
  has_many :items, through: :stores

  def self.from_omniauth!(access_token)
    user = User.find_or_create_by!(email: access_token.info['email'])
  end

  def admin?
    email.in?(ADMIN_EMAILS)
  end
end
