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
