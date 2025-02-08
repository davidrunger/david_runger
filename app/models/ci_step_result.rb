# == Schema Information
#
# Table name: ci_step_results
#
#  branch             :string           not null
#  created_at         :datetime         not null
#  github_run_attempt :integer          not null
#  github_run_id      :bigint           not null
#  id                 :bigint           not null, primary key
#  name               :string           not null
#  passed             :boolean          default(FALSE), not null
#  seconds            :float            not null
#  sha                :string           not null
#  started_at         :datetime         not null
#  stopped_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :bigint           not null
#
# Indexes
#
#  idx_on_name_github_run_id_github_run_attempt_96ff2b0b91  (name,github_run_id,github_run_attempt) UNIQUE
#  index_ci_step_results_on_user_id                         (user_id)
#
class CiStepResult < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: %i[github_run_id github_run_attempt] }
  validates :seconds, presence: true
  validates :started_at, presence: true
  validates :stopped_at, presence: true
  validates :passed, inclusion: { in: [true, false] }
  validates :github_run_id, presence: true
  validates :github_run_attempt, presence: true
  validates :branch, presence: true
  validates :sha, presence: true
end
