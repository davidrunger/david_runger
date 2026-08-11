class ProposalsController < ApplicationController
  self.container_classes = %w[p-8]

  before_action :set_proposal, only: %i[accept cancel confirm]

  def create
    authorize(Proposal)

    proposal = current_user.sent_proposals.pending.find_or_create_by(
      proposee_email: params[:spouse_email],
    )

    if !proposal.persisted?
      flash[:alert] = proposal.errors.full_messages.to_sentence
    elsif proposal.previously_new_record?
      delivery_limit =
        Email::UserGeneratedDeliveryLimiter.reserve(
          actor: current_user,
          recipient_email: proposal.proposee_email,
          category: :proposal,
        )

      if delivery_limit.permitted?
        ProposalMailer.proposal_created(proposal.id).deliver_later
        flash[:notice] = 'Invitation sent.'
      else
        flash[:alert] =
          "Invitation created. #{Email::UserGeneratedDeliveryLimiter::EMAIL_NOT_SENT_MESSAGE}"
      end
    else
      flash[:notice] = 'Invitation already pending.'
    end

    redirect_to(redirect_location || check_ins_path)
  end

  def confirm
    authorize(@proposal)
    @title = 'Confirm marriage proposal'
  end

  def accept
    authorize(@proposal)
    result = Proposals::Accept.new(
      proposal: @proposal,
      proposee: current_user,
    ).run

    if result.success?
      flash[:notice] = 'Marriage created.'
    else
      flash[:alert] = result.error_message
    end

    redirect_to(check_ins_path)
  end

  def cancel
    authorize(@proposal)
    result = Proposals::Cancel.new(proposal: @proposal).run

    if result.success?
      flash[:notice] = 'Invitation canceled.'
    else
      flash[:alert] = result.error_message
    end

    redirect_to(check_ins_path)
  end

  private

  def set_proposal
    @proposal =
      Proposal.
        includes(proposer: :marriage).
        find_by!(public_id: params.expect(:public_id))
  end
end
