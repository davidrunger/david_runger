namespace :assets do
  def run_logged_system_command(command)
    puts "Running system command '#{command}' ..."
    if system(command)
      puts '... success.'
    else
      puts '... failed.'
    end
  end

  desc 'clean yarn cache'
  task :clean_yarn_cache do
    run_logged_system_command('yarn cache clean')
  end

  desc 'delete the node_modules directory'
  task :rmrf_node_module do
    run_logged_system_command('rm -rf node_modules')
  end

  desc 'Uploads source maps to rollbar'
  task :upload_source_maps do
    SourceMapHelper.require_heroku!
    SourceMapHelper.upload_source_maps!
  end

  # Heroku sets the SOURCE_VERSION env variable only during deploys.
  # This task writes ENV['SOURCE_VERSION'] to a file so that it will be available in Heroku's slugs.
  desc 'Writes the git sha currently being deployed to a file'
  task :save_source_version do
    if ENV['SOURCE_VERSION'].present?
      File.write('SOURCE_VERSION', ENV['SOURCE_VERSION'])
    else
      puts "ENV['SOURCE_VERSION'] was not present!"
      abort
    end
  end
end

module SourceMapHelper
  class NotOnHerokuError < StandardError ; end
  class NoSourceMapError < StandardError ; end
  class SourceMapUploadError < StandardError ; end

  JS_FILES = (
    Dir['app/javascript/packs/**/*.js'].map { |path| path.match(%r{/([^/]+).js})[1] } +
      %w[styles] # Don't need CSS source maps. Also, styles are built into a CSS file on prod
  ).freeze
  ROLLBAR_SOURCE_MAP_URI = 'https://api.rollbar.com/api/1/sourcemap/'.freeze
  APP_URL_BASE = 'https://www.davidrunger.com'.freeze

  def self.on_heroku?
    ENV['HEROKU'].present?
  end

  def self.require_heroku!
    fail(NotOnHerokuError, 'Must be on Heroku!') unless on_heroku?
  end

  def self.manifest
    @manifest ||= JSON.parse(File.read('public/packs/manifest.json'))
  end

  def self.post_to_rollbar!(source_url:, source_map_path:)
    require('net/http/post/multipart')

    File.open(source_map_path) do |source_map_file|
      response = RestClient.post(
        ROLLBAR_SOURCE_MAP_URI,
        access_token: ENV['ROLLBAR_ACCESS_TOKEN'],
        environment: Rails.env,
        version: ENV['SOURCE_VERSION'],
        minified_url: source_url,
        source_map: source_map_file,
      )
      puts <<~LOG
        Posted source map #{source_map_path} for #{source_url}.
        Response code: #{response.code}
        Response body:
        #{response.body}
      LOG
    end
  end

  def self.upload_source_maps!
    JS_FILES.each do |file|
      js_path  = manifest["#{file}.js"]
      map_path = manifest["#{file}.js.map"]
      fail(NoSourceMapError, "Source map not found for #{js_path}") if map_path.blank?

      # build the full asset url
      source_url = "#{APP_URL_BASE}#{js_path}"
      full_local_map_path = Rails.root.join(File.join('public', map_path))

      begin
        post_to_rollbar!(source_url: source_url, source_map_path: full_local_map_path)
      rescue => error
        Rails.logger.error("Error posting source maps to Rollbar, error=#{error.inspect}")
        # wrap the original exception by raising and immediately rescuing
        begin
          raise(SourceMapUploadError, 'Failed to upload a source map')
        rescue SourceMapUploadError => e
          Rollbar.error(
            e,
            file: file,
            js_path: js_path,
            map_path: map_path,
            source_url: source_url,
            full_local_map_path: full_local_map_path,
            response_to_s: e.cause&.response.to_s,
          )
        end
      end
    end
  end
end

if Rails.env.production?
  Rake::Task['assets:precompile'].enhance(%w[
    assets:clean_yarn_cache
    assets:rmrf_node_module
    build_js_routes
  ]) do
    if SourceMapHelper.on_heroku?
      Rake::Task['assets:upload_source_maps'].invoke
      Rake::Task['assets:save_source_version'].invoke
    end
  end
end
