class ApplicationSerializer
  include Alba::Resource

  private

  def current_user
    params[:current_user]
  end
end
