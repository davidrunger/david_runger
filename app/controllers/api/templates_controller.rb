class Api::TemplatesController < ApplicationController
  def update
    template = current_user.templates.find(params[:id])
    template.update!(template_params)
    head :ok
  end

  private

  def template_params
    params.require(:template).permit(:body)
  end
end
