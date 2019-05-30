# frozen_string_literal: true

require Rails.root.join('db', 'datamigrate', 'populate_log_slugs.rb')

class AddSlugToLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :logs, :slug, :string
    populate_log_slugs
    change_column_null :logs, :slug, false
    add_index :logs, %i[user_id slug], unique: true
  end
end
