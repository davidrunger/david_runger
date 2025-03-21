class ModelGraphController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :skip_authorization, only: %i[index]
  before_action :skip_bootstrap_schema_validation, only: %i[index]

  def index
    @title = 'Model Graph'
    bootstrap(model_metadata: RungerRailsModelExplorer.model_metadata)
  end
end
