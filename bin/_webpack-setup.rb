puts 'Ensuring that compiled routes are up-to-date ...'
if File.exist?('app/javascript/rails_assets/routes.js')
  system('bin/rails app/javascript/rails_assets/routes.js')
else
  system('bin/rails build_js_routes')
end
puts 'Done checking/compiling routes.'
