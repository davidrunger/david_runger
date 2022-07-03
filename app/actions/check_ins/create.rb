# frozen_string_literal: true

class CheckIns::Create < ApplicationAction
  requires :marriage, Marriage

  returns :check_in, CheckIn, presence: true

  def execute
    check_in = marriage.check_ins.create!

    check_in.marriage.emotional_needs.each do |emotional_need|
      check_in.marriage.partners.each do |partner|
        NeedSatisfactionRating.create!(check_in:, emotional_need:, user: partner)
      end
    end

    result.check_in = check_in
  end
end
