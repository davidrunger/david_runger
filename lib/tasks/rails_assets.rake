desc 'Build named-routes JavaScript helper script'
file 'app/javascript/rails_assets/routes.js' => [:environment, 'config/routes.rb'] do
  puts 'Clearing Rails tmp cache ...'
  Rake::Task['tmp:cache:clear'].invoke

  puts 'Writing app/javascript/rails_assets/routes.js ...'
  rails_assets_directory_name = 'app/javascript/rails_assets'
  FileUtils.mkdir(rails_assets_directory_name) unless File.exists?(rails_assets_directory_name)
  JsRoutes.generate!('app/javascript/rails_assets/routes.js', exclude: /admin/)

  puts 'Done writing named routes JavaScript helpers to file.'
end
