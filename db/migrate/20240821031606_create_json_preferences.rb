class CreateJsonPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :json_preferences do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :preference_type, null: false
      t.jsonb :json, null: false

      t.timestamps
    end

    add_index :json_preferences, %i[user_id preference_type], unique: true
  end
end
