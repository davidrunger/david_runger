# frozen_string_literal: true

class Admin::UsersController < Admin::ApplicationController
  # To customize the behavior of this controller,
  # you can overwrite any of the RESTful actions. For example:
  #
  # def index
  #   super
  #   @resources = User.
  #     page(params[:page]).
  #     per(10)
  # end

  # Define a custom finder by overriding the `find_resource` method:
  # def find_resource(param)
  #   User.find_by!(slug: param)
  # end

  # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
  # for more information
  using BlankParamsAsNil

  def resource_params
    super.blank_params_as_nil(%w[phone])
  end
end
