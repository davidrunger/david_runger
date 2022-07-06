# frozen_string_literal: true

class NeedSatisfactionRatingSerializer < ActiveModel::Serializer
  attributes :id, :score

  belongs_to :emotional_need
end
