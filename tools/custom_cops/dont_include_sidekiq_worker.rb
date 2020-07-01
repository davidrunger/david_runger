# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
module CustomCops
  class DontIncludeSidekiqWorker < RuboCop::Cop::Cop
    MSG = 'Use `prepend ApplicationWorker` rather than `include Sidekiq::Worker`'

    def_node_matcher :including_sidekiq_worker?, <<~PATTERN
      (send ... :include (const (const ... :Sidekiq) :Worker))
    PATTERN

    def on_send(node)
      return unless including_sidekiq_worker?(node)

      add_offense(node)
    end

    def autocorrect(node)
      lambda do |corrector|
        corrector.replace(node, 'prepend ApplicationWorker')
      end
    end
  end
end
# rubocop:enable Style/ClassAndModuleChildren
