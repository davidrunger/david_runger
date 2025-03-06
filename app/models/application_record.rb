class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # from the `strip_attributes` gem https://github.com/rmm5t/strip_attributes
  strip_attributes

  class << self
    prepend Memoization

    memoize \
    def serializer_class
      "#{name}Serializer".constantize
    end

    def has_paper_trail_for_all_events # rubocop:disable Naming/PredicateName
      # Log all events, including `create` (which we omit by default).
      has_paper_trail(on: %i[create destroy touch update])
    end
  end

  def as_json
    serializer.as_json
  end
  # rubocop:enable Rails/Delegate

  # rubocop:disable Style/OptionHash
  def serializer(params = {})
    self.class.serializer_class.new(self, params:)
  end
  # rubocop:enable Style/OptionHash

  def class_id_string
    "#{self.class.name}:#{id}"
  end
end
