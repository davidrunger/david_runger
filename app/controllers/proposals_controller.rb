class ProposalsController < ApplicationController
  def create
    authorize(Marriage, :propose?)
    ProposalMailer.proposal_created(current_user.id, params[:spouse_email]).deliver_later
    flash[:notice] = 'Invitation sent.'
    redirect_to(redirect_location || check_ins_path)
  end

  def accept
    authorize(Marriage, :create?)
    Proposals::Accept.new(
      encoded_token: params[:token],
      proposee: current_user,
    ).run!
    flash[:notice] = 'Marriage created.'
    redirect_to(check_ins_path)
  end
end
