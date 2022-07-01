# frozen_string_literal: true

# == Schema Information
#
# Table name: emotional_needs
#
#  created_at  :datetime         not null
#  description :text
#  id          :bigint           not null, primary key
#  marriage_id :bigint           not null
#  name        :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_emotional_needs_on_marriage_id  (marriage_id)
#
class EmotionalNeed < ApplicationRecord
  belongs_to :marriage
  has_many :need_satisfaction_ratings, dependent: :destroy
end
