class Proposals::Accept < ApplicationAction
  prepend MemoWise

  requires :encoded_token, String
  requires :proposee, User

  def execute
    marriage.update!(partner_2: proposee)
    destroy_other_proposee_marriages
  end

  private

  def destroy_other_proposee_marriages
    Marriage.where(partner_1: proposee).where(partner_2: nil).find_each(&:destroy!)
  end

  memo_wise \
  def marriage
    proposer.marriage || Marriage.build(partner_1: proposer)
  end

  memo_wise \
  def proposer
    User.find(proposer_id)
  end

  memo_wise \
  def proposer_id
    JWT.decode(
      encoded_token,
      ENV.fetch('JWT_SECRET'),
      true,
      { algorithm: 'HS512' },
    ).dig(0, 'proposer_id')
  end
end
