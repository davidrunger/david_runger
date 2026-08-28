class AddNonnegativeCheckConstraintToItemsNeeded < ActiveRecord::Migration[8.1]
  def up
    execute(
      <<~SQL.squish,
        UPDATE items
        SET needed = 0
        WHERE needed < 0
      SQL
    )

    add_check_constraint(
      :items,
      'needed >= 0',
      name: 'items_needed_non_negative',
    )
  end

  def down
    remove_check_constraint(:items, name: 'items_needed_non_negative')
  end
end
