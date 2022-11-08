# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  created_at  :datetime         not null
#  email       :string           not null
#  id          :bigint           not null, primary key
#  preferences :jsonb            not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  extend Memoist

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
  has_many :text_log_entries, through: :logs
  has_many :workouts, dependent: :destroy
  has_many :need_satisfaction_ratings, dependent: :destroy
  has_many :check_in_submissions, dependent: :destroy

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

  memoize \
  def marriage
    Marriage.where(partner_1_id: id).or(Marriage.where(partner_2_id: id)).first
  end

  memoize \
  def spouse
    [marriage&.partner_1, marriage&.partner_2].compact.reject { _1.id == id }.first
  end

  def reload
    flush_cache # clear memoized methods
    super
  end
end
