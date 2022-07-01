# frozen_string_literal: true

class CheckInsController < ApplicationController
  self.container_classes = %w[p3]

  before_action :ensure_marriage, only: %i[index]
  before_action :set_check_in, only: %i[show update]

  def index
    authorize(CheckIn)
    @title = 'Marriage check-ins'
    @marriage = current_user.marriage.decorate
    render :index
  end

  def create
    authorize(CheckIn)
    check_in = CheckIns::Create.run!(marriage: current_user.marriage).check_in
    redirect_to(check_in_path(check_in))
  end

  def show
    authorize(@check_in, :show?)
  end

  def update
    authorize(@check_in, :update?)
    check_in_params[:need_satisfaction_rating].each do |id, attributes|
      need_satisfaction_rating = NeedSatisfactionRating.find(id)
      authorize(need_satisfaction_rating, :update?)
      need_satisfaction_rating.update!(attributes)
    end
    redirect_to(@check_in)
  end

  private

  def check_in_params
    params.require(:check_in).permit(need_satisfaction_rating: {})
  end

  def set_check_in
    @check_in = policy_scope(CheckIn).find(params[:id]).decorate
  end

  def ensure_marriage
    Marriage.create!(partner_1: current_user) if current_user.marriage.nil?
  end
end
