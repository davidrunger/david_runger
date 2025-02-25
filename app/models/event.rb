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
#  user_agent    :text
#  user_id       :bigint
#
# Indexes
#
#  index_events_on_admin_user_id  (admin_user_id)
#  index_events_on_ip             (ip)
#  index_events_on_type           (type)
#  index_events_on_user_id        (user_id)
#
class Event < ApplicationRecord
  # Tell ActiveRecord not to use 'type' column for Single Table Inheritance.
  self.inheritance_column = nil

  validates :stack_trace, presence: true
  validates :type, presence: true

  belongs_to :admin_user, optional: true
  belongs_to :user, optional: true

  class << self
    def create_with_stack_trace!(attributes)
      create!(attributes.merge(
        stack_trace:
          StackTraceFilter.new.
            application_stack_trace(ignore: [__FILE__]),
      ))
    end

    def ransackable_associations(_auth_object = nil)
      %w[admin_user user]
    end

    def ransackable_attributes(_auth_object = nil)
      %w[
        admin_user_id
        created_at
        data
        id
        ip
        isp
        location
        stack_trace
        type
        updated_at
        user_agent
        user_id
      ]
    end
  end
end
