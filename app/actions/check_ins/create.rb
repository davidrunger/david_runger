# frozen_string_literal: true

class CheckIns::Create < ApplicationAction
  requires :marriage, Marriage

  returns :check_in, CheckIn, presence: true

  def execute
    check_in = marriage.check_ins.create!
    marriage = check_in.marriage

    marriage.emotional_needs.each do |emotional_need|
      marriage.partners.each do |partner|
        NeedSatisfactionRating.create!(check_in:, emotional_need:, user: partner)
      end
    end

    CheckInsChannel.broadcast_to(
      marriage,
      { command: 'redirect', location: check_in_path(check_in) },
    )

    result.check_in = check_in
  end
end
