# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
require 'activeadmin' if defined?(Rails::Server) || (ENV['RAILS_ENV'] == 'test')
Rails.application.initialize!
