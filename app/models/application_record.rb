# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def serializer_class
      "#{name}Serializer".constantize
    end
  end

  def to_json(_options)
    serializer.to_json
  end

  # rubocop:disable Rails/Delegate
  def as_json
    serializer.as_json
  end
  # rubocop:enable Rails/Delegate

  def serializer
    self.class.serializer_class.new(self)
  end
end
