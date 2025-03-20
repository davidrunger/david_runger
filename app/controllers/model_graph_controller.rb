class ModelGraphController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization

  def index
    @title = 'Model Graph'
    bootstrap(model_metadata: RungerRailsModelExplorer.model_metadata)
  end
end
