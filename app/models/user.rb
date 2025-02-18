# == Schema Information
#
# Table name: users
#
#  created_at :datetime         not null
#  email      :string           not null
#  google_sub :string
#  id         :bigint           not null, primary key
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  prepend Memoization

  validates :email, presence: true, uniqueness: true, format: { with: /\A\S+@\S+\.\S+\z/ }

  has_many :auth_tokens, dependent: :destroy
  has_many :logs, dependent: :destroy
  has_many :log_shares, through: :logs
  has_many :quizzes, dependent: :destroy, foreign_key: 'owner_id', inverse_of: :owner
  has_many(
    :quiz_participations,
    dependent: :destroy,
    foreign_key: 'participant_id',
    inverse_of: :participant,
  )
  has_many :requests, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :items, through: :stores # must come after has_many :stores declaration
  has_many :log_entries, through: :logs
  has_many :workouts, dependent: :destroy
  has_many :need_satisfaction_ratings, dependent: :destroy
  has_many :check_in_submissions, dependent: :destroy
  has_many :json_preferences, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :ci_step_results, dependent: :destroy

  JsonPreference::Types.constants.each do |constant_name|
    scope_name = JsonPreference::Types.const_get(constant_name).to_sym

    has_one scope_name,
      ->(user) { user.json_preferences.public_send(scope_name) },
      class_name: 'JsonPreference',
      inverse_of: :user,
      dependent: :destroy
  end

  devise

  has_paper_trail

  before_destroy do |user|
    if user.reload.marriage
      marriage =
        Marriage.
          includes(
            check_ins: :need_satisfaction_ratings,
            emotional_needs: :need_satisfaction_ratings,
          ).
          find(user.marriage.id)

      marriage.destroy!
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at email id updated_at]
  end

  memoize \
  def marriage
    Marriage.where(partner_1_id: id).or(Marriage.where(partner_2_id: id)).first
  end

  memoize \
  def spouse
    [marriage&.partner_1, marriage&.partner_2].compact.reject { _1.id == id }.first
  end

  def reload
    reset_memo_wise # clear memoized methods
    super
  end

  def display_name
    email.split('@').first
  end
end
