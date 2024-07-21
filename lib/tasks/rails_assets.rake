desc 'Build named-routes JavaScript helper script'
task build_js_routes: :environment do
  require 'js-routes'

  puts 'Clearing Rails tmp cache ...'
  Rake::Task['tmp:cache:clear'].invoke

  puts 'Writing app/javascript/rails_assets/routes.js ...'
  FileUtils.mkdir_p('app/javascript/rails_assets')

  routes_path = 'rails_assets/routes.js'
  routes_full_path = "app/javascript/#{routes_path}"

  options = { exclude: /admin|google|login|rails|sidekiq/ }
  JsRoutes.generate!(routes_path, **options)
  File.write(routes_full_path.sub('.js', '.d.ts'), JsRoutes.definitions(**options))

  # HACK: fix a weird bug where `this` is somehow undefined when switching to Vite
  File.write(
    routes_full_path,
    File.read(routes_full_path).sub(/^}\)\.call\(this\);/, '}).call(this || window);'),
  )

  puts 'Done writing named routes JavaScript helpers to file (plus `.d.ts` file).'
end
