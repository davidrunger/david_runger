# frozen_string_literal: true

class WorkoutsController < ApplicationController
  def index
    @title = 'Workout'
    @description = 'Plan and execute a timed workout'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      workouts:
        ActiveModel::Serializer::CollectionSerializer.new(current_user.workouts),
    )
    render :index
  end
end
