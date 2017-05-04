class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  private

  def bootstrap(data)
  	@bootstrap_data ||= {}
  	@bootstrap_data.merge!(data)
  end

  def after_sign_out_path_for(resource_or_scope)
    templates_path
  end
end
