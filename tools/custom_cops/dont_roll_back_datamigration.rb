module CustomCops
  class DontRollBackDatamigration < RuboCop::Cop::Base
    MSG = 'Only use the `:rollback` keyword argument for testing. Remove before pushing.'

    def on_send(node)
      # Only examine calls to within_transaction.
      return unless node.method_name == :within_transaction

      # Check each argument; if it's a hash, inspect its pairs.
      node.arguments.each do |arg|
        if arg.hash_type?
          arg.pairs.each do |pair|
            key, _value = *pair

            # If the key is a symbol and equals :rollback, register an offense.
            if key.sym_type? && key.value == :rollback
              add_offense(pair, message: MSG)
            end
          end
        end
      end
    end
  end
end
