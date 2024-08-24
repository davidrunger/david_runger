class Api::BaseController < ApplicationController
  class SchemaValidationError < StandardError ; end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  def render_schema_json(data, **kwargs)
    data = resource_for_json_rendering(data)

    if Rails.env.local? && !(defined?(Runger.config) && Runger.config.skip_schema_validation?)
      # TIP: Generate the schema from sample response data using
      # https://jsonformatter.org/json-to-jsonschema .
      partial_schema_path = "#{params[:controller]}/#{params[:action]}".delete_prefix('api/')

      full_schema_path =
        Rails.root.join(
          "spec/support/schemas/#{partial_schema_path}.json",
        ).to_s

      schema_validation_errors =
        begin
          JSON::Validator.fully_validate(
            full_schema_path,
            data.is_a?(String) ? data : data.to_json,
            strict: true,
            validate_schema: true,
            clear_cache: true,
          )
        rescue *[
          JSON::Schema::JsonParseError,
          JSON::Schema::ReadFailed,
          JSON::Schema::SchemaParseError,
        ]
          if Rails.env.development?
            FileUtils.mkdir_p(File.dirname(full_schema_path))
            FileUtils.touch(full_schema_path)
            system("$EDITOR '#{full_schema_path}'", exception: true)
            copy_to_clipboard(data)
          end

          raise
        end

      if schema_validation_errors.present?
        copy_to_clipboard(data)
        raise(SchemaValidationError, schema_validation_errors.to_s)
      end
    end

    render(json: data, **kwargs)
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  private

  def copy_to_clipboard(data)
    if !Rails.env.development?
      return
    end

    string_to_copy =
      if data.is_a?(String)
        data
      else
        JSON.pretty_generate(data.as_json)
      end

    if string_to_copy.respond_to?(:cpp)
      string_to_copy.cpp

      puts('Copied JSON to clipboard.'.yellow)
    end
  end
end
