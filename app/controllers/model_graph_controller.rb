class ModelGraphController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization
  before_action :skip_bootstrap_schema_validation, only: %i[index]

  def index
    @title = 'Model Graph'
    bootstrap(model_metadata: RungerRailsModelExplorer.model_metadata)
  end
end
