# frozen_string_literal: true

class WorkoutsController < ApplicationController
  def index
    @description = 'Plan and execute a timed workout'
    render :index
  end
end
