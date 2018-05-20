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
