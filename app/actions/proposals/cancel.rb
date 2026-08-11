class Proposals::Cancel < ApplicationAction
  requires :proposal, Proposal

  fails_with :unavailable

  def execute
    ApplicationRecord.transaction do
      proposal.lock!

      if proposal.accepted_at.present?
        result.unavailable!('This proposal has already been accepted.')
      elsif proposal.canceled_at.nil?
        proposal.update!(canceled_at: Time.current)
      end
    end
  end
end
