class CreateLinkStatusExpectations < ActiveRecord::Migration[8.1]
  def change
    create_table :link_status_expectations do |t|
      t.text :url, null: false
      t.integer :status, null: false

      t.timestamps
    end

    add_index :link_status_expectations, %i[url status], unique: true
    add_check_constraint(
      :link_status_expectations,
      'status BETWEEN 100 AND 999',
      name: 'link_status_expectations_status_range',
    )
  end
end
