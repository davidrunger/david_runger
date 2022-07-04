# frozen_string_literal: true

# == Schema Information
#
# Table name: emotional_needs
#
#  created_at  :datetime         not null
#  description :text
#  id          :bigint           not null, primary key
#  marriage_id :bigint           not null
#  name        :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_emotional_needs_on_marriage_id  (marriage_id)
#
FactoryBot.define do
  factory :emotional_need do
    name { Faker::Emotion.unique.noun.capitalize }
    description { Faker::Company.unique.bs.capitalize }
  end
end
