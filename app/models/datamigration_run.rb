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
class DatamigrationRun < ApplicationRecord
  validates :developer, presence: true
  validates :name, presence: true

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[completed_at created_at developer id name updated_at]
    end
  end
end
