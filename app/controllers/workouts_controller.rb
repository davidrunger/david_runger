# frozen_string_literal: true

class WorkoutsController < ApplicationController
  def index
    authorize(Workout)
    @title = 'Workout'
    @description = 'Plan and execute a timed workout'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      workouts:
        ActiveModel::Serializer::CollectionSerializer.new(current_user.workouts),
      others_workouts: ActiveModel::Serializer::CollectionSerializer.new(
        policy_scope(Workout).
          where.not(user: current_user).
          order(created_at: :desc).
          limit(15).
          includes(:user),
      ),
    )
    render :index
  end
end
