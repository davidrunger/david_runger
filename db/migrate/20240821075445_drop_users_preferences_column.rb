class DropUsersPreferencesColumn < ActiveRecord::Migration[7.2]
  def change
    remove_column(:users, :preferences, :jsonb)
  end
end
