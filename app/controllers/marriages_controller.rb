class MarriagesController < ApplicationController
  self.container_classes = CheckInsController.container_classes

  before_action :ensure_no_spouse, only: %i[new]

  def show
    @marriage = current_user.marriage.decorate
    authorize(@marriage, :show?)
  end

  def new
    authorize(Marriage)
    @pending_proposals = current_user.sent_proposals.pending.order(created_at: :desc)
    render :new
  end

  def destroy
    marriage = Marriage.with_eager_loading_for_destroy.find(current_user.marriage.id)
    authorize(marriage)
    marriage.destroy!
    flash[:notice] = 'Your marriage has been ended.'
    redirect_to(check_ins_path)
  end

  private

  def ensure_no_spouse
    if current_user.spouse
      flash[:alert] = "You are already married to #{current_user.spouse.email}."
      redirect_to(check_ins_path)
    end
  end
end
