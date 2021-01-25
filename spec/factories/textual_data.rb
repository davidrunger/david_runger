# frozen_string_literal: true

# == Schema Information
#
# Table name: textual_data
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#  value      :text             not null
#

FactoryBot.define do
  factory :textual_datum do
    value { Faker::Movies::VForVendetta.quote }
  end
end
