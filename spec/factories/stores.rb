# == Schema Information
#
# Table name: stores
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string           not null
#  notes      :text
#  private    :boolean          default(FALSE), not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#  viewed_at  :datetime         not null
#
# Indexes
#
#  index_stores_on_user_id  (user_id)
#

FactoryBot.define do
  factory :store do
    name { Faker::Company.name }
    association :user
    viewed_at { [1.day.ago, 1.week.ago, 1.month.ago].sample }
    notes { 'member phone number: 619-867-5309' }
  end
end
