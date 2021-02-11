# frozen_string_literal: true

class Admin::QuizDecorator < Draper::Decorator
  delegate_all

  class << self
    def object_class_name
      'Quiz'
    end
  end

  def to_param
    id
  end
end
