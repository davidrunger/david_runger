# frozen_string_literal: true

module ContainerClassable
  extend ActiveSupport::Concern

  included do
    helper_method :container_classes
  end

  class_methods do
    def container_classes=(classes)
      @container_classes = classes
    end

    def container_classes
      @container_classes || []
    end
  end

  def container_classes
    self.class.container_classes
  end
end
