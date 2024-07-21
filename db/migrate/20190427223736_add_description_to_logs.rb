class AddDescriptionToLogs < ActiveRecord::Migration[5.2]
  def change
    add_column :logs, :description, :string
  end
end
