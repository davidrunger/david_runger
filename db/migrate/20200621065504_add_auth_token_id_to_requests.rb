# frozen_string_literal: true

class AddAuthTokenIdToRequests < ActiveRecord::Migration[6.1]
  def change
    add_reference :requests, :auth_token, foreign_key: true
  end
end
