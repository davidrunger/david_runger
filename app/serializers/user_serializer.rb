# == Schema Information
#
# Table name: users
#
#  created_at :datetime         not null
#  email      :string           not null
#  google_sub :string
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class UserSerializer < ApplicationSerializer
  typelize_from User

  class Basic < UserSerializer
    attributes(*%i[email id])
  end

  class WithEmojiBoosts < Basic
    typelize 'Array<EmojiDataWithBoostedName>'
    attribute(:emoji_boosts) do |user|
      user.emoji_boosts&.json || []
    end
  end

  class WithDefaultWorkout < Basic
    typelize 'WorkoutPlan'
    attribute(:default_workout) do |user|
      user.default_workout&.json
    end
  end
end
