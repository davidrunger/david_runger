# == Schema Information
#
# Table name: weight_logs
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  note       :string
#  updated_at :datetime         not null
#  user_id    :bigint(8)        not null
#  weight     :float            not null
#
# Indexes
#
#  index_weight_logs_on_user_id_and_created_at  (user_id,created_at)
#

class WeightLog < ApplicationRecord
  belongs_to :user, optional: true # not actually optional, but this saves an unnecessary DB query

  validates :user_id, presence: true
  validates :weight, presence: true
end
