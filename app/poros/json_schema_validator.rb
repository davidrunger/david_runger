class JsonSchemaValidator
  class NonconformingData < StandardError ; end

  prepend Memoization

  def initialize(data, controller_action:)
    @data = data
    @controller_action = controller_action
  end

  # TIP: Generate the schema from sample response data using
  # https://jsonformatter.org/json-to-jsonschema .
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def validated_data
    if (
      Rails.env.local? &&
        !IS_DOCKER &&
        !(defined?(Runger.config) && Runger.config.skip_schema_validation?) &&
        !(universal_bootstrap_data? && !schema_file_exists?) &&
        schema_validation_errors.present?
    )
      copy_data_to_clipboard_and_open_schema_converter_if_development

      raise(
        NonconformingData,
        "Violation of #{relative_schema_path} : #{schema_validation_errors}.",
      )
    else
      @data
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  private

  memoize \
  def schema_validation_errors
    JSON::Validator.fully_validate(
      absolute_schema_path,
      json_string_to_validate,
      validate_schema: true,
      clear_cache: true,
    )
  rescue *[
    JSON::Schema::JsonParseError,
    JSON::Schema::ReadFailed,
    JSON::Schema::SchemaParseError,
  ]
    if Rails.env.development?
      # :nocov:
      create_and_open_schema_file_in_editor
      copy_data_to_clipboard_and_open_schema_converter_if_development
      # :nocov:
    end

    raise
  end

  def json_string_to_validate
    @data.is_a?(String) ? @data : @data.to_json
  end

  memoize \
  def universal_bootstrap_data?
    @data.is_a?(Hash) &&
      (@data.keys - %i[current_user nonce toast_messages]).empty?
  end

  memoize \
  def schema_file_exists?
    File.exist?(absolute_schema_path)
  end

  memoize \
  def absolute_schema_path
    Rails.root.join(relative_schema_path).to_s
  end

  memoize \
  def relative_schema_path
    if api?
      "spec/support/schemas/#{@controller_action}.json"
    else
      "spec/support/schemas/bootstrap/#{@controller_action}.json"
    end
  end

  memoize \
  def api?
    @controller_action.start_with?('api/')
  end

  def create_and_open_schema_file_in_editor
    # :nocov:
    if Rails.env.development?
      FileUtils.mkdir_p(File.dirname(absolute_schema_path))
      FileUtils.touch(absolute_schema_path)
      system("$EDITOR '#{absolute_schema_path}'", exception: true)
    end
    # :nocov:
  end

  def copy_data_to_clipboard_and_open_schema_converter_if_development
    if Rails.env.development?
      # :nocov:
      string_to_copy =
        if @data.is_a?(String)
          @data
        else
          JSON.pretty_generate(@data.as_json)
        end

      if string_to_copy.respond_to?(:cpp)
        string_to_copy.cpp

        puts('Copied JSON to clipboard.'.yellow)
      end

      system('open https://jsonformatter.org/json-to-jsonschema', exception: true)
      # :nocov:
    end
  end
end
