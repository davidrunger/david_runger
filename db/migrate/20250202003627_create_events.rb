class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :type, null: false
      t.references :user
      t.references :admin_user
      t.jsonb :data
      t.string :ip
      t.string :isp
      t.string :location
      t.string :stack_trace, array: true, default: [], null: false

      t.timestamps
    end

    add_index :events, :type
    add_index :events, :ip
  end
end
