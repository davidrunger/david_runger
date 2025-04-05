module Classable
  extend ActiveSupport::Concern

  included do
    class_attribute :body_classes
    class_attribute :container_classes
    class_attribute :html_classes

    helper_method :body_classes
    helper_method :container_classes
    helper_method :html_classes
  end
end
