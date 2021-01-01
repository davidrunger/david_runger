# frozen_string_literal: true

class AddAdminUserIdToRequests < ActiveRecord::Migration[6.1]
  def change
    add_reference :requests, :admin_user, foreign_key: true
  end
end
