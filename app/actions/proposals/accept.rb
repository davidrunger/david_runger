class Proposals::Accept < ApplicationAction
  requires :proposal, Proposal
  requires :proposee, User

  fails_with :unavailable

  def execute
    ApplicationRecord.transaction do
      proposal.lock!

      locked_users =
        User.
          where(id: [proposal.proposer_id, proposee.id]).
          order(:id).
          lock.
          index_by(&:id)
      locked_proposer = locked_users.fetch(proposal.proposer_id)
      locked_proposee = locked_users.fetch(proposee.id)

      user_memberships =
        MarriageMembership.
          where(user_id: locked_users.keys).
          order(:id).
          lock.
          index_by(&:user_id)
      marriages =
        Marriage.
          where(id: user_memberships.values.map(&:marriage_id)).
          order(:id).
          lock.
          index_by(&:id)
      marriage_memberships =
        MarriageMembership.
          where(marriage_id: marriages.keys).
          order(:id).
          lock.
          to_a

      proposer_marriage = marriages[user_memberships[locked_proposer.id]&.marriage_id]
      proposee_marriage = marriages[user_memberships[locked_proposee.id]&.marriage_id]

      unavailable_message = unavailable_message(
        locked_proposer:,
        locked_proposee:,
        marriage_memberships:,
        proposer_marriage:,
        proposee_marriage:,
      )

      if unavailable_message
        result.unavailable!(unavailable_message)
      else
        accept_proposal!(
          locked_proposer:,
          locked_proposee:,
          proposer_marriage:,
          proposee_marriage:,
        )
      end
    end
  end

  private

  def unavailable_message(
    locked_proposer:,
    locked_proposee:,
    marriage_memberships:,
    proposer_marriage:,
    proposee_marriage:
  )
    return 'This proposal has already been accepted.' if proposal.accepted_at.present?

    if !proposal.proposee_email.casecmp?(locked_proposee.email)
      return 'This proposal was sent to a different email address.'
    end

    if locked_proposer == locked_proposee
      return 'You cannot accept your own proposal.'
    end

    target_marriage_is_full =
      proposer_marriage.present? &&
      proposer_marriage != proposee_marriage &&
      marriage_memberships.count { it.marriage_id == proposer_marriage.id } >= 2

    if target_marriage_is_full
      return "#{locked_proposer.email}'s marriage already has two partners."
    end

    nil
  end

  def accept_proposal!(locked_proposer:, locked_proposee:, proposer_marriage:, proposee_marriage:)
    target_marriage = proposer_marriage || Marriage.create!(partners: [locked_proposer])

    if proposee_marriage != target_marriage
      destroy_marriage!(proposee_marriage) if proposee_marriage
      target_marriage.partners << locked_proposee
    end

    proposal.update!(accepted_at: Time.current)
  end

  def destroy_marriage!(marriage)
    Marriage.with_eager_loading_for_destroy.find(marriage.id).destroy!
  end
end
