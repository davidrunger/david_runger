module CustomCops
  class DontIncludeSidekiqWorker < RuboCop::Cop::Base
    extend RuboCop::Cop::AutoCorrector

    MSG =
      'Use `prepend ApplicationWorker` rather than `include Sidekiq::Worker` ' \
      'or `include Sidekiq::Job`'

    def_node_matcher :including_sidekiq_worker?, <<~PATTERN
      (send ... :include (const (const ... :Sidekiq) ${:Worker :Job}))
    PATTERN

    def on_send(node)
      return unless including_sidekiq_worker?(node)

      add_offense(node) do |corrector|
        corrector.replace(node, 'prepend ApplicationWorker')
      end
    end
  end
end
