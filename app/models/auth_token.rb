# == Schema Information
#
# Table name: auth_tokens
#
#  created_at   :datetime         not null
#  id           :bigint           not null, primary key
#  last_used_at :datetime
#  name         :text
#  secret       :text             not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_auth_tokens_on_secret              (secret)
#  index_auth_tokens_on_user_id_and_secret  (user_id,secret) UNIQUE
#
class AuthToken < ApplicationRecord
  validates :secret, presence: true, uniqueness: { scope: :user_id }

  belongs_to :user
  has_many :requests, dependent: :nullify

  has_paper_trail_for_all_events
end
