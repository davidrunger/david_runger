# == Schema Information
#
# Table name: admin_users
#
#  created_at :datetime         not null
#  email      :string           not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
# Indexes
#
#  index_admin_users_on_email  (email) UNIQUE
#
class AdminUser < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  has_many :events, dependent: :destroy

  devise

  has_paper_trail

  def display_name
    email.split('@').first
  end
end
