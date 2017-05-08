class TemplatesController < ApplicationController
  def index
    @title = 'Templates'
    render :index
  end

  def new
    @title = 'New Template'
    @template = Template.new
    render :new
  end

  def create
    @template = current_user.templates.new(template_params.merge(body: Template::SAMPLE_BODY))
    if @template.save
      flash[:notice] = 'Template created'
      redirect_to template_path(@template)
    else
      flash[:alert] = @template.errors.full_messages
      render :new
    end
  end

  def show
    @template = current_user.templates.find(params[:id])
    @title = @template.name
    bootstrap(template: @template.as_json)
    render :show
  end

  private

  def template_params
    params.require(:template).permit(:name)
  end
end
