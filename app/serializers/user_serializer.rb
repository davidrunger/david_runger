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
    ATTRIBUTES = %i[email id].freeze

    attributes(*ATTRIBUTES)
  end

  class Public < UserSerializer
    attributes(*%i[id public_name])

    typelize 'string | null'
    attribute(:gravatar_url) do |user|
      # If the user doesn't want to share a name, they probably don't want to share a gravatar URL.
      if user.public_name.present?
        email_hash = Digest::SHA256.hexdigest(user.email.downcase)
        "https://gravatar.com/avatar/#{email_hash}?s=32&d=robohash&r=r"
      end
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
