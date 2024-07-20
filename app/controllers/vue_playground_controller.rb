class VuePlaygroundController < ApplicationController
  def index
    authorize(:vue_playground)
  end

  private

  def pundit_user
    current_admin_user
  end
end
