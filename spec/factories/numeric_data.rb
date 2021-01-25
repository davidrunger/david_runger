# frozen_string_literal: true

# == Schema Information
#
# Table name: numeric_data
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#  value      :float            not null
#

FactoryBot.define do
  factory :numeric_datum do
    value { rand(200) }
  end
end
