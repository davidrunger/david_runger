class JsonSchemaValidator
  class NonconformingData < StandardError ; end

  prepend MemoWise

  def initialize(data, controller_action:)
    @data = data
    @controller_action = controller_action
  end

  # TIP: Generate the schema from sample response data using
  # https://jsonformatter.org/json-to-jsonschema .
  def validated_data
    if (
      Rails.env.local? && !(defined?(Runger.config) && Runger.config.skip_schema_validation?) &&
        schema_validation_errors.present?
    )
      copy_data_to_clipboard

      raise(NonconformingData, schema_validation_errors.to_s)
    else
      @data
    end
  end

  private

  memo_wise \
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
      copy_data_to_clipboard
      # :nocov:
    end

    raise
  end

  def json_string_to_validate
    @data.is_a?(String) ? @data : @data.to_json
  end

  memo_wise \
  def absolute_schema_path
    if api?
      Rails.root.join(
        "spec/support/schemas/#{@controller_action}.json",
      ).to_s
    else
      Rails.root.join(
        "spec/support/schemas/bootstrap/#{@controller_action}.json",
      ).to_s
    end
  end

  memo_wise \
  def api?
    @controller_action.start_with?('api/')
  end

  def create_and_open_schema_file_in_editor
    if Rails.env.development?
      # :nocov:
      FileUtils.mkdir_p(File.dirname(absolute_schema_path))
      FileUtils.touch(absolute_schema_path)
      system("$EDITOR '#{absolute_schema_path}'", exception: true)
      # :nocov:
    end
  end

  def copy_data_to_clipboard
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
      # :nocov:
    end
  end
end
