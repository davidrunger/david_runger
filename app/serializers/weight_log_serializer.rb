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

class WeightLogSerializer < ActiveModel::Serializer
  attributes :created_at, :id, :note, :weight

  def created_at
    decimal_precision = 0
    weight_log.created_at.iso8601(decimal_precision)
  end

  private

  def weight_log
    object
  end
end
