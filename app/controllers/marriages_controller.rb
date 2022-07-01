# frozen_string_literal: true

class MarriagesController < ApplicationController
  self.container_classes = CheckInsController.container_classes

  def show
    @marriage = current_user.marriage.decorate
    authorize(@marriage, :show?)
  end
end
