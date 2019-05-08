# == Schema Information
#
# Table name: logs
#
#  created_at  :datetime         not null
#  description :string
#  id          :bigint           not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_logs_on_user_id_and_name  (user_id,name) UNIQUE
#  index_logs_on_user_id_and_slug  (user_id,slug) UNIQUE
#

class LogSerializer < ActiveModel::Serializer
  attributes :description, :id, :name, :slug

  has_many :log_inputs
end
