# frozen_string_literal: true

class EmotionalNeedsController < ApplicationController
  self.container_classes = %w[p3]

  before_action :set_emotional_need, only: %i[destroy edit history update]

  def create
    authorize(EmotionalNeed)
    current_user.marriage.emotional_needs.create!(emotional_need_params)
    redirect_to(marriage_path)
  end

  def edit
    authorize(@emotional_need)
  end

  def update
    authorize(@emotional_need)
    @emotional_need.update!(emotional_need_params)
    redirect_to(marriage_path)
  end

  def destroy
    authorize(@emotional_need)
    @emotional_need.destroy!
    redirect_to(marriage_path)
  end

  def history
    authorize(@emotional_need, :show?)
    rating_user =
      case params[:rated_user]
      when 'partner' then current_user
      else current_user.marriage.decorate.other_partner
      end
    @emotional_need = EmotionalNeed.find(params[:id])
    @rating_data =
      NeedSatisfactionRating.
        where(
          user_id: rating_user,
          emotional_need: @emotional_need,
        ).
        order('need_satisfaction_ratings.created_at').
        pluck(:created_at, :score)
  end

  private

  def emotional_need_params
    params.require(:emotional_need).permit(:name, :description)
  end

  def set_emotional_need
    @emotional_need = policy_scope(EmotionalNeed).find(params[:id])
  end
end
