# frozen_string_literal: true

class AddTimestampsToRequests < ActiveRecord::Migration[5.1]
  def up
    change_table(:requests, &:timestamps)
  end

  def down
    remove_column :requests, :created_at
    remove_column :requests, :updated_at
  end
end
