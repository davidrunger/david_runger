# frozen_string_literal: true

class EmotionalNeedsController < ApplicationController
  def create
    authorize(EmotionalNeed)
    current_user.marriage.emotional_needs.create!(emotional_need_params)
    redirect_to(marriage_path)
  end

  private

  def emotional_need_params
    params.require(:emotional_need).permit(:name, :description)
  end
end
