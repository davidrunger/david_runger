# frozen_string_literal: true

class RemoveCurrentSignInAtColumnFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :current_sign_in_at, :datetime
  end
end
