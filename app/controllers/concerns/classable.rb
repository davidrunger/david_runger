module Classable
  extend ActiveSupport::Concern

  included do
    class_attribute :container_classes
    class_attribute :html_classes

    helper_method :container_classes
    helper_method :html_classes
  end

  def container_classes
    self.class.container_classes
  end

  def html_classes
    self.class.html_classes
  end
end
