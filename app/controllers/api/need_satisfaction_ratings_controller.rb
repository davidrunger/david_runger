# frozen_string_literal: true

class Api::NeedSatisfactionRatingsController < ApplicationController
  before_action :set_need_satisfaction_rating, only: %i[update]

  def update
    authorize(@need_satisfaction_rating)
    NeedSatisfactionRatings::Update.run!(
      need_satisfaction_rating: @need_satisfaction_rating,
      attributes: need_satisfaction_rating_params.to_h,
      current_user:,
    )
    render json: @need_satisfaction_rating
  end

  private

  def set_need_satisfaction_rating
    @need_satisfaction_rating = policy_scope(NeedSatisfactionRating).find(params[:id])
  end

  def need_satisfaction_rating_params
    params.require(:need_satisfaction_rating).permit(:score)
  end
end
