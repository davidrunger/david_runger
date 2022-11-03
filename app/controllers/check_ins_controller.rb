# frozen_string_literal: true

class CheckInsController < ApplicationController
  self.container_classes = %w[p3]

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
      check_in: ActiveModelSerializers::SerializableResource.new(
        @check_in,
        serializer: CheckInSerializer,
      ),
      user_ratings_of_partner:
        ActiveModel::Serializer::CollectionSerializer.new(
          check_in_need_satisfaction_ratings.
            where(user: current_user).
            includes(:emotional_need).
            order('emotional_needs.name'),
        ),
    }

    if @check_in.completed_by_both_partners?
      bootstrap_data[:partner_ratings_of_user] =
        ActiveModel::Serializer::CollectionSerializer.new(
          check_in_need_satisfaction_ratings.
            where(user: current_user.marriage.decorate.other_partner).
            includes(:emotional_need).
            order('emotional_needs.name'),
        )
    elsif @check_in.completed_by_partner?
      bootstrap_data[:partner_ratings_hidden_reason] = '[hidden until you submit your answers]'
    else
      bootstrap_data[:partner_ratings_hidden_reason] = "They didn't complete it yet."
    end

    bootstrap_data
  end
end
