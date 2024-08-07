class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # from the `strip_attributes` gem https://github.com/rmm5t/strip_attributes
  strip_attributes

  class << self
    prepend MemoWise

    memo_wise \
    def serializer_class
      "#{name}Serializer".constantize
    end
  end

  # rubocop:disable Rails/Delegate
  def as_json
    serializer.as_json
  end
  # rubocop:enable Rails/Delegate

  # rubocop:disable Style/OptionHash
  def serializer(params = {})
    self.class.serializer_class.new(self, params:)
  end
  # rubocop:enable Style/OptionHash
end
