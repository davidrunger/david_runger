class Api::BaseController < ApplicationController
  class SchemaValidationError < StandardError ; end

  def render_schema_json(data, schema: nil, **kwargs)
    if Rails.env.local? && !(defined?(Runger.config) && Runger.config.skip_schema_validation?)
      # TIP: Generate the schema from sample response data using https://app.quicktype.io/ .
      partial_schema_path =
        schema ||
        "#{params[:controller]}/#{params[:action]}".delete_prefix('api/')
      full_schema_path = "spec/support/schemas/#{partial_schema_path}.json"
      schema_validation_errors =
        JSON::Validator.fully_validate(
          full_schema_path,
          data.to_json,
          strict: true,
          validate_schema: true,
        )

      if schema_validation_errors.present?
        raise(SchemaValidationError, schema_validation_errors.to_s)
      end
    end

    render(json: data, **kwargs)
  end
end
