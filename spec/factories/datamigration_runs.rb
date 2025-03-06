# == Schema Information
#
# Table name: datamigration_runs
#
#  completed_at :datetime
#  created_at   :datetime         not null
#  developer    :string           not null
#  id           :bigint           not null, primary key
#  name         :string           not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_datamigration_runs_on_developer  (developer)
#  index_datamigration_runs_on_name       (name)
#
FactoryBot.define do
  factory :datamigration_run do
    developer { 'davidjrunger@gmail.com' }
    name { 'DestroyOrphanedLogEntryData' }
    created_at { 1.week.ago }

    trait(:completed) do
      completed_at { created_at + 1.minute }
      updated_at { completed_at }
    end
  end
end
