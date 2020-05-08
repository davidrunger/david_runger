# frozen_string_literal: true

# == Schema Information
#
# Table name: logs
#
#  created_at  :datetime         not null
#  data_label  :string           not null
#  data_type   :string           not null
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
  attributes :data_label, :data_type, :description, :id, :name, :slug

  belongs_to :user, serializer: LogOwnerSerializer
  has_many :log_shares
end
