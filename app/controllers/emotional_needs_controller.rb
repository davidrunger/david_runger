# frozen_string_literal: true

class EmotionalNeedsController < ApplicationController
  before_action :set_emotional_need, only: %i[destroy edit update]

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

  private

  def emotional_need_params
    params.require(:emotional_need).permit(:name, :description)
  end

  def set_emotional_need
    @emotional_need = policy_scope(EmotionalNeed).find(params[:id])
  end
end
