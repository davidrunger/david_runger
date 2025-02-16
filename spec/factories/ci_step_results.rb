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
FactoryBot.define do
  factory :ci_step_result do
    created_at_time = 10.days.ago
    github_run_id_seed = Kernel.rand(100_000_000)

    association(:user)

    branch { 'main' }
    created_at { created_at_time }
    github_run_attempt { rand(1..2) }
    sequence(:github_run_id) { |n| github_run_id_seed + n }
    name { 'RunFeatureTests' }
    passed { true }
    seconds { rand(80..90) + rand }
    sha { SecureRandom.hex(20) }
    started_at { created_at_time - 90.seconds }
    stopped_at { created_at_time - 5.seconds }
    updated_at { created_at_time }

    trait(:wall_clock_time) do
      name { 'WallClockTime' }
    end

    trait(:cpu_time) do
      name { 'CpuTime' }
    end

    trait(:feature_tests) do
      name { 'RunFeatureTests' }
    end

    trait(:unit_tests) do
      name { 'RunUnitTests' }
    end
  end
end
