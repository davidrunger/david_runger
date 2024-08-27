class Api::BaseController < ApplicationController
  def render_schema_json(data, **kwargs)
    render(json: schema_validated_data(data), **kwargs)
  end
end
