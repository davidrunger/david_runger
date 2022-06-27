# frozen_string_literal: true

desc 'Build named-routes JavaScript helper script'
task build_js_routes: :environment do
  require 'js-routes'

  puts 'Clearing Rails tmp cache ...'
  Rake::Task['tmp:cache:clear'].invoke

  puts 'Writing app/javascript/rails_assets/routes.js ...'
  rails_assets_directory_name = 'app/javascript/rails_assets'
  FileUtils.mkdir_p(rails_assets_directory_name)
  routes_path = 'rails_assets/routes.js'
  JsRoutes.generate!(routes_path, exclude: /admin|google|login|rails|sidekiq/)
  app_javascript_path = "app/javascript/#{routes_path}"
  # HACK: fix a weird bug where `this` is somehow undefined when switching to Vite
  File.write(
    app_javascript_path,
    File.read(app_javascript_path).sub(/^}\)\.call\(this\);/, '}).call(this || window);'),
  )

  puts 'Done writing named routes JavaScript helpers to file.'
end
