class CreateAuthenticatedSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :authenticated_sessions do |t|
      t.string :identifier, null: false
      t.references :authenticatable, polymorphic: true, null: false, index: false
      t.string :authentication_kind, null: false
      t.string :initial_ip, null: false
      t.string :latest_ip, null: false
      t.text :initial_user_agent, null: false
      t.text :latest_user_agent, null: false
      t.datetime :last_active_at, null: false
      t.datetime :revoked_at
      t.references :initiated_by_authenticated_session,
                   foreign_key: {
                     to_table: :authenticated_sessions,
                   }

      t.timestamps
    end
    add_index :authenticated_sessions, :identifier, unique: true
    add_index :authenticated_sessions,
              %i[authenticatable_type authenticatable_id revoked_at],
              name: :index_authenticated_sessions_for_account_listing
  end
end
