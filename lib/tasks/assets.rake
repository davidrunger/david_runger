# frozen_string_literal: true

namespace :assets do
  def run_logged_system_command(command)
    puts "Running system command '#{command}' ..."
    if system(command)
      puts '... success.'
    else
      puts '... failed.'
    end
  end

  desc 'Uploads source maps to rollbar'
  task :upload_source_maps do
    DeployAssetsHelper.require_heroku!
    SourceMapHelper.upload_source_maps!
  end

  # Heroku sets the SOURCE_VERSION env variable only during deploys.
  # This task writes ENV['SOURCE_VERSION'] to a file so that it will be available in Heroku's slugs.
  desc 'Writes the git sha currently being deployed to a file'
  task :save_source_version do
    if ENV['SOURCE_VERSION'].present?
      File.write('SOURCE_VERSION', ENV.fetch('SOURCE_VERSION', nil))
    else
      puts "ENV['SOURCE_VERSION'] was not present!"
      abort
    end
  end

  desc 'Boot a server in development that serves assets in a production-like manner'
  task :production_asset_server do
    run_logged_system_command('rm -rf node_modules/')
    run_logged_system_command('rm -rf public/vite/ public/vite-dev/')
    run_logged_system_command('rm -f app/javascript/rails_assets/routes.js')
    run_logged_system_command('DISABLE_SPRING=1 bin/rails build_js_routes')
    run_logged_system_command('NODE_ENV=production yarn install')
    run_logged_system_command('NODE_ENV=production bin/vite build --force')
    run_logged_system_command('PRODUCTION_ASSET_CONFIG=1 DISABLE_SPRING=1 bin/rails server')
  end
end

module DeployAssetsHelper
  class NotOnHerokuError < StandardError ; end

  def self.on_heroku?
    ENV['HEROKU'].present?
  end

  def self.require_heroku!
    fail(NotOnHerokuError, 'Must be on Heroku!') unless on_heroku?
  end
end

module SourceMapHelper
  class NoSourceMapError < StandardError ; end
  class SourceMapUploadError < StandardError ; end

  JS_FILES =
    Dir['app/javascript/packs/**/*.js'].map { |path| path.match(%r{/([^/]+).js})[1] }.freeze
  ROLLBAR_SOURCE_MAP_URI = 'https://api.rollbar.com/api/1/sourcemap/'
  APP_URL_BASE = 'https://www.davidrunger.com'

  class << self
    extend Memoist

    memoize \
    def manifest
      JSON.parse(File.read('public/packs/manifest.json'))
    end

    def post_to_rollbar!(source_url:, source_map_path:)
      connection =
        Faraday.new do |conn|
          conn.request(:multipart)
          conn.response(:json)
        end

      response = connection.post(
        ROLLBAR_SOURCE_MAP_URI,
        {
          access_token: ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil),
          environment: Rails.env,
          version: ENV.fetch('SOURCE_VERSION', nil),
          minified_url: source_url,
          source_map: Faraday::Multipart::FilePart.new(File.open(source_map_path), 'text/plain'),
        },
      )
      puts <<~LOG
        Posted source map #{source_map_path} for #{source_url}.
        Response status: #{response.status}
        Response body: #{response.body}
      LOG
    end

    def upload_source_maps!
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
end

if Rails.env.production?
  Rake::Task['assets:precompile'].enhance(%w[build_js_routes]) do
    if DeployAssetsHelper.on_heroku?
      Rake::Task['assets:upload_source_maps'].invoke
      Rake::Task['assets:save_source_version'].invoke
    end
  end
end
