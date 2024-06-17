# frozen_string_literal: true

class CheckInsController < ApplicationController
  self.container_classes = %w[p-8]

  before_action :ensure_marriage, only: %i[index]
  before_action :set_check_in, only: %i[show]

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
    @title = "Marriage Check-In ##{@check_in.check_in_number}"
    bootstrap(show_bootstrap_data)
  end

  private

  def set_check_in
    @check_in = policy_scope(CheckIn).find(params[:id]).decorate
  end

  def ensure_marriage
    Marriage.create!(partner_1: current_user) if current_user.marriage.nil?
  end

  def show_bootstrap_data
    check_in_need_satisfaction_ratings = @check_in.need_satisfaction_ratings

    bootstrap_data = {
      check_in: @check_in.serializer,
      user_ratings_of_partner:
        NeedSatisfactionRatingSerializer.new(
          check_in_need_satisfaction_ratings.
            where(user: current_user).
            includes(:emotional_need).
            order('emotional_needs.name'),
        ),
    }

    bootstrap_data[:partner_ratings_of_user] =
      if @check_in.submitted_by_both_partners?
        NeedSatisfactionRatingSerializer.new(
          check_in_need_satisfaction_ratings.
            where(user: current_user.marriage.decorate.other_partner).
            includes(:emotional_need).
            order('emotional_needs.name'),
        )
      else
        bootstrap_data[:partner_ratings_hidden_reason] =
          if @check_in.submitted_by_partner?
            '[hidden until you submit your answers]'
          else
            "They didn't complete it yet."
          end
        []
      end

    bootstrap_data
  end
end
