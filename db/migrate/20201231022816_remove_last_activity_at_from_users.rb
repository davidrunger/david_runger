# frozen_string_literal: true

class RemoveLastActivityAtFromUsers < ActiveRecord::Migration[6.2]
  def change
    remove_column :users, :last_activity_at, :datetime
  end
end
