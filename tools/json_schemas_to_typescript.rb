module JsonSchemasToTypescript
  SCHEMA_DIRECTORY = 'spec/support/schemas'
  API_SCHEMA_DIRECTORY = "#{SCHEMA_DIRECTORY}/api".freeze
  BOOTSTRAP_SCHEMA_DIRECTORY = "#{SCHEMA_DIRECTORY}/bootstrap".freeze

  types_directory = 'app/javascript/types'
  BOOTSTRAP_TYPES_DIRECTORY =
    Rails.root.join("#{types_directory}/bootstrap").to_s.freeze
  RESPONSE_TYPES_DIRECTORY =
    Rails.root.join("#{types_directory}/responses").to_s.freeze

  SCHEMA_DIRECTORY_REGEX = %r{\A#{SCHEMA_DIRECTORY}/(api|bootstrap)/}

  class << self
    def initialize_listener(app)
      return if @initialized
      # NOTE: We don't want to regenerate the files each time we run specs, for example.
      return if !defined?(Rails::Server)

      @initialized = true

      app.config.after_initialize do
        listener =
          ::Listen.to(Rails.root.join(SCHEMA_DIRECTORY).to_s) do |changed, added, removed|
            JsonSchemasToTypescript.write_files(
              changed: changed.map { relative_path(it) },
              added: added.map { relative_path(it) },
              removed: removed.map { relative_path(it) },
            )
          end

        listener.start
      end
    end

    # rubocop:disable Metrics
    def write_files(changed: nil, added: nil, removed: nil)
      write_all = (changed.nil? && added.nil? && removed.nil?) || removed.present?

      if write_all
        [BOOTSTRAP_TYPES_DIRECTORY, RESPONSE_TYPES_DIRECTORY].each do |directory|
          FileUtils.rm_rf(directory)
          FileUtils.mkdir_p(directory)
        end
      end

      [
        [API_SCHEMA_DIRECTORY, 'Response', RESPONSE_TYPES_DIRECTORY],
        [BOOTSTRAP_SCHEMA_DIRECTORY, 'Bootstrap', BOOTSTRAP_TYPES_DIRECTORY],
      ].each do |schema_directory, type_suffix, types_directory|
        Dir["#{schema_directory}/**/*.json"].each do |schema_path|
          if write_all || schema_path.in?(changed) || schema_path.in?(added)
            response_name =
              schema_path.
                gsub(SCHEMA_DIRECTORY_REGEX, '').
                delete_suffix('.json').
                split('/').
                then do |path_fragments|
                  if path_fragments[-1] == 'index'
                    [*path_fragments[0..-3].map(&:singularize), *path_fragments[-2..]]
                  else
                    path_fragments.map(&:singularize)
                  end
                end.
                join('/').
                camelize.
                gsub('::', '')

            type_name = "#{response_name}#{type_suffix}"

            file_to_write = "#{types_directory}/#{type_name}.ts"

            system(<<~SH.squish)
              ./node_modules/.bin/quicktype
                --src-lang schema
                #{schema_path}
                --out #{file_to_write}
                --just-types
            SH

            # Only export the first interface in the file. (All are exported by quicktype.)
            # Swap `Date` to `string`.
            File.write(
              file_to_write,
              File.read(file_to_write).
                gsub(/^export interface/, 'interface').
                sub(/^interface/, 'export interface').
                gsub(/\bDate\b/, 'string'),
            )

            # Work around this quicktype bug:
            # https://github.com/glideapps/quicktype/issues/ 2481
            if JSON.parse(File.read(schema_path))['type'] == 'array'
              file_content = File.read(file_to_write)

              main_interface =
                file_content.
                  match(/^export interface (?<main_interface>\w+) {/).
                  []('main_interface')

              main_interface_element_name = "#{main_interface}Element"

              file_content.gsub!(
                /^export interface #{main_interface} {/,
                "interface #{main_interface_element_name} {",
              )

              File.write(file_to_write, <<~JS)
                export type #{main_interface} = Array<#{main_interface_element_name}>

                #{file_content}
              JS
            end
          end
        end
      end
    end
    # rubocop:enable Metrics

    private

    def relative_path(absolute_path)
      Pathname.new(absolute_path).relative_path_from(Rails.root).to_s
    end
  end
end
