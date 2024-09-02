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
class JsonPreference < ApplicationRecord
  module Types
    DEFAULT_WORKOUT = 'default_workout'
    EMOJI_BOOSTS = 'emoji_boosts'
  end

  JsonPreference::Types.constants.each do |constant_name|
    constant_value = JsonPreference::Types.const_get(constant_name)

    scope(constant_value, -> { where(preference_type: constant_value) })
  end

  belongs_to :user

  validates :preference_type, presence: true
  validates :json, length: { minimum: 0, allow_nil: false }
  validates :preference_type, uniqueness: { scope: :user_id }
end
