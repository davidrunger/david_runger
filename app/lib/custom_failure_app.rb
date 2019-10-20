# frozen_string_literal: true

class CustomFailureApp < Devise::FailureApp
  def route(_scope)
    :login_path
  end
end
