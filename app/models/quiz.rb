# frozen_string_literal: true

# == Schema Information
#
# Table name: quizzes
#
#  created_at :datetime         not null
#  id         :bigint           not null, primary key
#  name       :string
#  owner_id   :bigint           not null
#  status     :string           default("unstarted"), not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_quizzes_on_owner_id  (owner_id)
#
class Quiz < ApplicationRecord
  include Hashid::Rails

  validates :status, presence: true, inclusion: %w[unstarted active closed].map(&:freeze).freeze

  belongs_to :owner, class_name: 'User'

  has_many :quiz_participations, dependent: :destroy
  has_many :participants, through: :quiz_participations
end
