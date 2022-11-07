# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  created_at  :datetime         not null
#  email       :string           not null
#  id          :bigint           not null, primary key
#  preferences :jsonb            not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class UserSerializer < ApplicationSerializer
  attributes(*%i[email id preferences])

  class ForSpouse < UserSerializer
    filtered_attributes(%i[email id])
  end
end
