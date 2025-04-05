class Marriages::Create < ApplicationAction
  # rubocop:disable Layout/LineLength
  DEFAULT_EMOTIONAL_NEEDS = {
    'Affection' => 'The nonsexual expression of care through hugs, kisses, words, cards, and courtesies; creating an environment that clearly and repeatedly expresses care.',
    'Sexual fulfillment' => 'A sexual experience that is predictably enjoyable and frequent enough for you.',
    'Intimate conversation' => 'Talking about topics of personal interest, feelings, opinions, and plans.',
    'Recreational companionship' => 'Leisure activities with at least one other person.',
    'Honesty and openness' => 'Truthful and frank expressions of positive and negative feelings, events of the past, daily events and schedule, and plans for the future; not leaving a false impression.',
    'Physical attractiveness' => 'Viewing physical traits of the opposite sex that are aesthetically and/or sexually pleasing.',
    'Financial support' => 'Provision of the financial resources to house, feed, and clothe your family at a standard of living acceptable to you.',
    'Domestic support' => 'Management of the household tasks and care of the children (if any are at home) that create a home environment that offers you a refuge from the stresses of life.',
    'Family commitment' => 'Provision for the moral and educational development of your children within the family unit.',
    'Admiration' => 'Being shown respect, value, and appreciation.',
  }.freeze
  # rubocop:enable Layout/LineLength

  requires :proposer, User

  def execute
    ApplicationRecord.transaction do
      marriage = Marriage.create!(partners: [proposer])

      DEFAULT_EMOTIONAL_NEEDS.each do |name, description|
        marriage.emotional_needs.create!(name:, description:)
      end
    end
  end
end
