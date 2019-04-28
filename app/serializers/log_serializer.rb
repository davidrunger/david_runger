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

  has_many :log_inputs

  private

  def log
    object
  end
end
