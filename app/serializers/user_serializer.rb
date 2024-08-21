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
  class Basic < UserSerializer
    attributes(*%i[email id])
  end

  class WithEmojiBoosts < Basic
    attribute(:emoji_boosts) do |user|
      user.emoji_boosts&.json || []
    end
  end

  class WithPreferences < Basic
    attributes :preferences
  end
end
