# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

if Rails.env.production?
  # https://github.com/heroku/heroku-buildpack-ruby/pull/892#issuecomment-548897899
  assets_precompile_task = Rake.application.tasks.find { |task| task.name == 'assets:precompile' }
  if assets_precompile_task.present?
    assets_precompile_task.prerequisites.delete('yarn:install')
  end
end
