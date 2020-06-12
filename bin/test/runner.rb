# frozen_string_literal: true

module Test ; end
module Test::Tasks ; end

require_relative '../../config/application.rb'
require 'English'
require 'benchmark'
require File.join(File.dirname(__FILE__), 'diff_helpers.rb')
require File.join(File.dirname(__FILE__), 'task_helpers.rb')
Dir[File.join(File.dirname(__FILE__), 'tasks', '*.rb')].each { require _1 }
require File.join(File.dirname(__FILE__), 'requirements_resolver.rb')

Rails.application.load_tasks

class Test::Runner < Pallets::Workflow
  required_tasks = Test::RequirementsResolver.new.required_tasks
  ap('Running these tasks:')
  ap(required_tasks.map(&:name).sort)
  ap('NOT running these tasks:')
  ap((Test::RequirementsResolver::DEPENDENCY_MAP.keys - required_tasks).map(&:name).sort)

  Test::RequirementsResolver::DEPENDENCY_MAP.slice(*required_tasks).each do |task, prerequisites|
    if Array(prerequisites).reject(&:nil?).empty?
      task(task)
    else
      task(task => Array(prerequisites) & required_tasks)
    end
  end

  class << self
    attr_accessor :exit_code
  end

  self.exit_code = 0
end
