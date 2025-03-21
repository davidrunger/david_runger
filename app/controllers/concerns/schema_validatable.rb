module SchemaValidatable
  extend ActiveSupport::Concern

  included do
    helper_method :schema_validated_data
  end

  private

  def schema_validated_data(data)
    data = resource_for_json_rendering(data)

    if @skip_bootstrap_schema_validation
      data
    else
      JsonSchemaValidator.new(
        data,
        controller_action: "#{params[:controller]}/#{params[:action]}",
      ).validated_data
    end
  end

  def skip_bootstrap_schema_validation
    @skip_bootstrap_schema_validation = true
  end
end
