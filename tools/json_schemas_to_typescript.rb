module JsonSchemasToTypescript
  RESPONSE_TYPES_DIRECTORY =
    Rails.root.join('app/javascript/types/responses').to_s.freeze
  SCHEMA_DIRECTORY = 'spec/support/schemas'.freeze

  class << self
    def initialize_listener(app)
      return if @initialized
      # NOTE: We don't want to regenerate the files each time we run specs, for example.
      return if !defined?(Rails::Server)

      @initialized = true

      app.config.after_initialize do
        listener =
          ::Listen.to(Rails.root.join(SCHEMA_DIRECTORY).to_s) do |_changed, _added, _removed|
            JsonSchemasToTypescript.write_files
          end

        listener.start
      end

      app.config.to_prepare do
        JsonSchemasToTypescript.write_files
      end
    end

    def write_files
      FileUtils.rm_rf(RESPONSE_TYPES_DIRECTORY)

      Dir["#{SCHEMA_DIRECTORY}/**/*.json"].each do |schema_path|
        response_name =
          schema_path.
            delete_prefix("#{SCHEMA_DIRECTORY}/").
            delete_suffix('.json').
            split('/').
            map(&:singularize).
            join('/').
            camelize.
            gsub('::', '')

        type_name = "#{response_name}Response"

        file_to_write = "#{RESPONSE_TYPES_DIRECTORY}/#{type_name}.ts"

        typescript_content = <<~JS
          // This is a generated file. Do not edit this file directly.

          import { FromSchema } from 'json-schema-to-ts';

          const schema = #{File.read(schema_path).rstrip} as const;

          export type #{type_name} = FromSchema<typeof schema>;
        JS

        FileUtils.mkdir_p(RESPONSE_TYPES_DIRECTORY)
        File.write(file_to_write, typescript_content)
      end
    end
  end
end
