# == Schema Information
#
# Table name: users
#
#  created_at  :datetime         not null
#  email       :string           not null
#  google_sub  :string
#  id          :bigint           not null, primary key
#  public_name :string
#  updated_at  :datetime         not null
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
  has_many :comments, dependent: :nullify

  has_one :marriage_membership, dependent: :destroy
  has_one :marriage, through: :marriage_membership

  JsonPreference::Types.constants.each do |constant_name|
    scope_name = JsonPreference::Types.const_get(constant_name).to_sym

    # rubocop:disable Rails/HasManyOrHasOneDependent
    # Don't specify a :dependent option because it would be redundant with
    # `has_many :json_preferences, dependent: :destroy` and it causes an N+1.
    has_one scope_name,
      ->(user) { user.json_preferences.public_send(scope_name) },
      class_name: 'JsonPreference',
      inverse_of: :user
    # rubocop:enable Rails/HasManyOrHasOneDependent
  end

  devise

  has_paper_trail_for_all_events

  before_destroy do |user|
    if (marriage = user.marriage)
      marriage.destroy!
    end
  end

  class << self
    def ransackable_attributes(_auth_object = nil)
      %w[created_at email id updated_at]
    end

    def with_eager_loading_for_destroy
      includes(
        :auth_tokens,
        :need_satisfaction_ratings,
        logs: [:log_shares, { log_entries: :log_entry_datum }],
        marriage: {
          check_ins: %i[check_in_submissions need_satisfaction_ratings],
          emotional_needs: :need_satisfaction_ratings,
        },
        quiz_participations: %i[quiz_question_answer_selections],
        quizzes: {
          participations: :quiz_question_answer_selections,
          questions: { answers: :selections },
        },
        stores: :items,
      )
    end
  end

  memoize \
  def spouse
    if marriage
      marriage.partners.excluding(self).first
    end
  end

  def reload
    reset_memo_wise # clear memoized methods
    super
  end

  def display_name
    email.split('@').first
  end
end
