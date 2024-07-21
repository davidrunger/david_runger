class VuePlaygroundController < ApplicationController
  require_admin_user!

  def index
    authorize(:vue_playground)
  end
end
