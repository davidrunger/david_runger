# == Schema Information
#
# Table name: json_preferences
#
#  created_at      :datetime         not null
#  id              :bigint           not null, primary key
#  json            :jsonb            not null
#  preference_type :string           not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_json_preferences_on_user_id_and_preference_type  (user_id,preference_type) UNIQUE
#
FactoryBot.define do
  factory :json_preference do
    association(:user)
    json do
      [
        {
          symbol: '😢',
          boostedName: 'tears',
        },
      ]
    end

    trait(:emoji_boosts) do
      preference_type { JsonPreference::Types::EMOJI_BOOSTS }
    end
  end
end
