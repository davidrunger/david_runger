# frozen_string_literal: true

class Api::CheckInsController < ApplicationController
  before_action :set_check_in, only: %i[update]

  def update
    authorize(@check_in, :update?)
    check_in_params[:need_satisfaction_rating].each do |id, attributes|
      need_satisfaction_rating = NeedSatisfactionRating.find(id)
      authorize(need_satisfaction_rating, :update?)
      need_satisfaction_rating.update!(attributes)
    end
    render json: @check_in
  end

  private

  def check_in_params
    params.require(:check_in).permit(need_satisfaction_rating: {})
  end

  def set_check_in
    @check_in = policy_scope(CheckIn).find(params[:id]).decorate
  end
end
