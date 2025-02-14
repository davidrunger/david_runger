module Classable
  extend ActiveSupport::Concern

  included do
    helper_method :container_classes
    helper_method :html_classes
  end

  class_methods do
    def container_classes=(classes)
      @container_classes = classes
    end

    def container_classes
      @container_classes || []
    end

    def html_classes=(classes)
      @html_classes = classes
    end

    def html_classes
      @html_classes || []
    end
  end

  def container_classes
    self.class.container_classes
  end

  def html_classes
    self.class.html_classes
  end
end
