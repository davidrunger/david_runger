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
    attr_reader :start_time

    def register_tasks_and_run
      print_config
      register_tasks
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      new.run
    end

    def run_once_config_is_confirmed
      if Test::RequirementsResolver.verify?
        confirm_config
      else
        system('clear')
        register_tasks_and_run
      end
    end

    memoize \
    def required_tasks
      Test::RequirementsResolver.new.required_tasks
    end

    def print_config
      system('clear')

      ap('Running these tasks:')
      ap(required_tasks.map(&:name).map { _1.gsub('Test::Tasks::', '') }.sort)
      ap('NOT running these tasks:')
      ap(
        (Pallets::Task.descendants - required_tasks).
          map(&:name).
          map { _1.gsub('Test::Tasks::', '') }.
          sort,
      )
    end

    def confirm_config
      print_config
      print("\n^ Does that config look good? [y]n")
      response = $stdin.getch

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
          # loop until the user hits enter (which will make `STDIN.ready?` true)
          sleep(0.1)
          next if !$stdin.ready?

          # take these actions once the user has hit enter (confirming that the setup looks good)
          @listener.stop # stop listening for further changes to `.tests.yml`
          $stdin.gets while $stdin.ready? # pull/clear the user's input from STDIN
          break
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
