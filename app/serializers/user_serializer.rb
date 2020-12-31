# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  created_at    :datetime         not null
#  email         :string           not null
#  id            :bigint           not null, primary key
#  phone         :string
#  sms_allowance :float            default(1.0), not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class UserSerializer < ActiveModel::Serializer
  attributes :email, :id, :phone
end
