class MarriagesController < ApplicationController
  self.container_classes = CheckInsController.container_classes

  before_action :ensure_no_spouse, only: %i[new]

  def show
    @marriage = current_user.marriage.decorate
    authorize(@marriage, :show?)
  end

  def new
    authorize(Marriage)
    render :new
  end

  private

  def ensure_no_spouse
    if current_user.spouse
      flash[:alert] = "You are already married to #{current_user.spouse.email}."
      redirect_to(check_ins_path)
    end
  end
end
