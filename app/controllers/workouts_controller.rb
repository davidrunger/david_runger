class WorkoutsController < ApplicationController
  def index
    authorize(Workout)
    @title = 'Workout'
    @description = 'Plan and execute a timed workout'
    bootstrap(
      current_user: UserSerializer.new(current_user),
      workouts: WorkoutSerializer.new(
        current_user.workouts.
          order(created_at: :desc).
          limit(8),
      ),
      others_workouts: WorkoutSerializer.new(
        policy_scope(Workout).
          where.not(user: current_user).
          order(created_at: :desc).
          limit(8).
          includes(:user),
      ),
    )
    render :index
  end
end
