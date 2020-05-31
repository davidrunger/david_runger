# frozen_string_literal: true

# == Schema Information
#
# Table name: logs
#
#  created_at               :datetime         not null
#  data_label               :string           not null
#  data_type                :string           not null
#  description              :string
#  id                       :bigint           not null, primary key
#  name                     :string           not null
#  publicly_viewable        :boolean          default(FALSE), not null
#  reminder_last_sent_at    :datetime
#  reminder_time_in_seconds :integer
#  slug                     :string           not null
#  updated_at               :datetime         not null
#  user_id                  :bigint           not null
#
# Indexes
#
#  index_logs_on_user_id_and_name  (user_id,name) UNIQUE
#  index_logs_on_user_id_and_slug  (user_id,slug) UNIQUE
#

FactoryBot.define do
  factory :log do
    association :user
    data_label { 'Weight (lbs)' }
    data_type { 'number' }
    description { 'Weight in pounds' }
    name { 'Weight' }
    reminder_time_in_seconds { Integer(3.days) }
    reminder_last_sent_at { 1.day.ago }
  end
end
