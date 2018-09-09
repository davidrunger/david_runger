# == Schema Information
#
# Table name: logs
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#
# Indexes
#
#  index_logs_on_user_id_and_name  (user_id,name) UNIQUE
#

class Log < ApplicationRecord
  belongs_to :user
  has_many :log_entries, dependent: :destroy
  has_many :log_inputs, dependent: :destroy
  validates :name, presence: true, uniqueness: {scope: :user_id}
end
