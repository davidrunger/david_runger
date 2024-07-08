# frozen_string_literal: true

class PublicFilePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      @user.public_files
    end
  end
end
