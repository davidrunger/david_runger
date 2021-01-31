# frozen_string_literal: true

desc 'Build named-routes JavaScript helper script'
task build_js_routes: :environment do
  require 'js-routes'

  puts 'Clearing Rails tmp cache ...'
  Rake::Task['tmp:cache:clear'].invoke

  puts 'Writing app/javascript/rails_assets/routes.js ...'
  rails_assets_directory_name = 'app/javascript/rails_assets'
  FileUtils.mkdir(rails_assets_directory_name) unless File.exist?(rails_assets_directory_name)
  JsRoutes.generate!(
    'app/javascript/rails_assets/routes.js',
    exclude: /admin|google|rails|sidekiq/,
    namespace: 'Routes',
  )

  puts 'Done writing named routes JavaScript helpers to file.'
end

desc 'Check for changes to routes.rb & recompile JS routes if needed'
file 'app/javascript/rails_assets/routes.js' => [:environment, 'config/routes.rb'] do
  Rake::Task['build_js_routes'].invoke
end
