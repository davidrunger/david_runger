# frozen_string_literal: true

# == Schema Information
#
# Table name: emotional_needs
#
#  created_at  :datetime         not null
#  description :text
#  id          :bigint           not null, primary key
#  marriage_id :bigint           not null
#  name        :string           not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_emotional_needs_on_marriage_id_and_name  (marriage_id,name) UNIQUE
#
FactoryBot.define do
  factory :emotional_need do
    name { "#{Faker::Emotion.unique.noun.capitalize}-#{SecureRandom.alphanumeric(5)}" }
    description { Faker::Company.unique.bs.capitalize }
  end
end
