# frozen_string_literal: true

module Test ; end
module Test::Tasks ; end

require_relative '../../config/application.rb'
require 'English'
require 'benchmark'
require 'io/console'
require File.join(File.dirname(__FILE__), 'diff_helpers.rb')
require File.join(File.dirname(__FILE__), 'task_helpers.rb')
Dir[File.join(File.dirname(__FILE__), 'tasks', '*.rb')].each { require _1 }
require File.join(File.dirname(__FILE__), 'requirements_resolver.rb')

Rails.application.load_tasks

class Test::Runner < Pallets::Workflow
  class << self
    extend Memoist

    attr_accessor :exit_code

    def register_tasks_and_run
      register_tasks
      new.run
    end

    def run_once_config_is_confirmed
      if ENV.key?('TRAVIS')
        register_tasks_and_run
      else
        confirm_config
      end
    end

    memoize \
    def required_tasks
      Test::RequirementsResolver.new.required_tasks
    end

    def print_config
      system('clear') if !ENV.key?('TRAVIS')

      ap('Running these tasks:')
      ap(required_tasks.map(&:name).sort)
      ap('NOT running these tasks:')
      ap((Pallets::Task.descendants - required_tasks).map(&:name).sort)
    end

    def confirm_config
      print_config
      print("\n^ Does that config look good? [y]n")
      response = STDIN.getch

      if response == "\u0003" # ctrl-c
        exit(1)
      elsif response.gsub(/\n|\r/, '').downcase.in?(['', 'y'])
        puts
      else
        system('$EDITOR bin/test/.tests.yml')

        @listener =
          Listen.to("#{Dir.pwd}/bin/test/", only: /\A.tests.yml\z/) do |_modified, _added, _removed|
            # reset memoized methods
            flush_cache
            Test::RequirementsResolver.flush_cache

            print_config

            puts('What about now? Hit enter to confirm.')
          end
        @listener.start

        loop do
          sleep(0.1)
          # wait until the user hits enter (which will make `STDIN.ready?` true)
          if STDIN.ready?
            STDIN.gets while STDIN.ready? # clear the user's input from STDIN
            break
          end
        end
      end

      register_tasks_and_run
    end

    def register_tasks
      Test::RequirementsResolver.dependency_map.slice(*required_tasks).each do |task, prerequisites|
        if Array(prerequisites).reject(&:nil?).empty?
          task(task)
        else
          task(task => Array(prerequisites) & required_tasks)
        end
      end
    end
  end

  self.exit_code = 0
end
