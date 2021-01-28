# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  created_at    :datetime         not null
#  email         :string           not null
#  id            :bigint           not null, primary key
#  phone         :string
#  sms_allowance :float            default(1.0), not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  ADMIN_EMAILS = %w[davidjrunger@gmail.com].map(&:freeze).freeze

  validates :email, presence: true, uniqueness: true
  validates :phone, format: { with: /\A1[[:digit:]]{10}\z/ }, allow_nil: true

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
  has_many :sms_records, dependent: :destroy
  has_many :stores, dependent: :destroy
  has_many :items, through: :stores # must come after has_many :stores declaration
  has_many :text_log_entries, through: :logs
  has_many :workouts, dependent: :destroy

  devise

  def admin?
    email.in?(ADMIN_EMAILS)
  end

  def sms_usage
    sms_records.sum(:cost)
  end
end
