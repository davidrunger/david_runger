# == Schema Information
#
# Table name: users
#
#  created_at  :datetime         not null
#  email       :string           not null
#  google_sub  :string
#  id          :bigint           not null, primary key
#  public_name :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class UserSerializer < ApplicationSerializer
  decorate_with UserDecorator
  typelize_from User

  class Basic < UserSerializer
    attributes(*%i[email id])
  end

  class Public < UserSerializer
    attributes(*%i[id])

    typelize 'string'
    attribute(:public_name, &:public_name_with_fallback)

    typelize 'string'
    attribute(:gravatar_url) do |user|
      email_hash = Digest::SHA256.hexdigest(user.email.downcase)
      "https://gravatar.com/avatar/#{email_hash}?s=32&d=robohash&r=r"
    end
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
