# frozen_string_literal: true

module Monkeypatches::MakeAllRequestsAsJson
  private

  # list of verbs taken from here:
  # https://github.com/rails/rails-controller-testing/blob/a60b3da/lib/rails/controller/testing/integration.rb#L7
  http_verbs = %w[get post patch put head delete]
  http_verbs.each do |method|
    define_method(method) do |*args, **kwargs|
      # rubocop:disable Performance/CollectionLiteralInLoop
      super(*args, **{ as: :json }.merge(kwargs))
      # rubocop:enable Performance/CollectionLiteralInLoop
    end
  end
end
