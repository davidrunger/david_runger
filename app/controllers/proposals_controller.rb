# frozen_string_literal: true

class ProposalsController < ApplicationController
  def create
    authorize(Marriage, :propose?)
    ProposalMailer.proposal_created(current_user.id, params[:spouse_email]).deliver_later
    flash[:notice] = 'Invitation sent.'
    redirect_to(check_ins_path)
  end

  def accept
    authorize(Marriage, :create?)
    proposer_id =
      JWT.decode(
        params[:token],
        Rails.application.credentials.jwt_secret,
        true,
        { algorithm: 'HS512' },
      ).dig(0, 'proposer_id')
    proposer = User.find(proposer_id)
    marriage = proposer.marriage || Marriage.build(partner_1: proposer)
    marriage.partner_2 = current_user
    marriage.save!
    flash[:notice] = 'Marriage created.'
    redirect_to(check_ins_path)
  end
end
