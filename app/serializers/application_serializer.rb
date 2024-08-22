class ApplicationSerializer
  include Alba::Resource
  include Typelizer::DSL

  private

  def current_user
    params[:current_user]
  end
end
