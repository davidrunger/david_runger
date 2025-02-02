# == Schema Information
#
# Table name: events
#
#  admin_user_id :bigint
#  created_at    :datetime         not null
#  data          :jsonb
#  id            :bigint           not null, primary key
#  ip            :string
#  isp           :string
#  location      :string
#  stack_trace   :string           default([]), not null, is an Array
#  type          :string           not null
#  updated_at    :datetime         not null
#  user_id       :bigint
#
# Indexes
#
#  index_events_on_admin_user_id  (admin_user_id)
#  index_events_on_ip             (ip)
#  index_events_on_type           (type)
#  index_events_on_user_id        (user_id)
#
FactoryBot.define do
  factory :event do
    association :admin_user
    association :user
    stack_trace do
      [
        '/home/david/code/david_runger/app/controllers/api/events_controller.rb:11:in ' \
        "'Api::EventsController#create'",
      ]
    end
    type { 'clicked_external_link' }
  end
end
