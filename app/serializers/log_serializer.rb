# == Schema Information
#
# Table name: logs
#
#  created_at  :datetime         not null
#  description :string
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  updated_at  :datetime         not null
#  user_id     :bigint(8)        not null
#
# Indexes
#
#  index_logs_on_user_id_and_name  (user_id,name) UNIQUE
#

class LogSerializer < ActiveModel::Serializer
  attributes :description, :id, :name

  has_many :log_entries do
    ordered_entries = object.log_entries_ordered
    is_text_log = object.log_inputs.any? { |input| input.type == 'LogInputs::TextLogInput' }
    is_text_log ? ordered_entries.last(3) : ordered_entries
  end
  has_many :log_inputs

  # def log_entries
  #   ActiveModel::Serializer::CollectionSerializer.new(log.log_entries)
  # end

  # def log_
  #   ActiveModel::Serializer::CollectionSerializer.new(log.log_entries)
  # end

  private

  def log
    object
  end
end
