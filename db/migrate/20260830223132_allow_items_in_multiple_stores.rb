class AllowItemsInMultipleStores < ActiveRecord::Migration[8.1]
  def up
    add_reference(:items, :user, foreign_key: true, index: false)
    execute(<<~SQL.squish)
      UPDATE items
      SET user_id = stores.user_id
      FROM stores
      WHERE items.store_id = stores.id
    SQL
    change_column_null(:items, :user_id, false)

    create_table :item_availabilities do |t|
      t.references :item, foreign_key: true, index: false, null: false
      t.references :store, foreign_key: true, null: false

      t.timestamps
    end
    add_index(
      :item_availabilities,
      %i[item_id store_id],
      unique: true,
    )

    execute(<<~SQL.squish)
      INSERT INTO item_availabilities (item_id, store_id, created_at, updated_at)
      SELECT id, store_id, created_at, updated_at
      FROM items
    SQL

    remove_index(:items, name: 'index_items_on_store_id_and_name')
    remove_reference(:items, :store, foreign_key: true, index: false)

    combine_same_name_items
    add_index(:items, %i[user_id name], unique: true)
  end

  def down
    remove_index(:items, %i[user_id name])

    add_reference(:items, :store, foreign_key: true, index: false)
    execute(<<~SQL.squish)
      UPDATE items
      SET store_id = item_store_ids.store_id
      FROM (
        SELECT item_id, MIN(store_id) AS store_id
        FROM item_availabilities
        GROUP BY item_id
      ) AS item_store_ids
      WHERE items.id = item_store_ids.item_id
    SQL
    change_column_null(:items, :store_id, false)
    add_index(:items, %i[store_id name], unique: true)

    drop_table(:item_availabilities)
    remove_reference(:items, :user, foreign_key: true)
  end

  private

  def combine_same_name_items
    # Keep the lowest-ID item in each user/name group and give it the group's
    # highest needed count.
    execute(<<~SQL.squish)
      WITH item_groups AS (
        SELECT user_id, name, MIN(id) AS item_id, MAX(needed) AS needed
        FROM items
        GROUP BY user_id, name
      )
      UPDATE items
      SET needed = item_groups.needed
      FROM item_groups
      WHERE items.id = item_groups.item_id
    SQL

    # Copy every store availability in each group to its surviving item. If
    # multiple grouped items were available at the same store, keep one row.
    execute(<<~SQL.squish)
      INSERT INTO item_availabilities (item_id, store_id, created_at, updated_at)
      SELECT item_groups.item_id,
        item_availabilities.store_id,
        item_availabilities.created_at,
        item_availabilities.updated_at
      FROM item_availabilities
      INNER JOIN items ON items.id = item_availabilities.item_id
      INNER JOIN (
        SELECT user_id, name, MIN(id) AS item_id
        FROM items
        GROUP BY user_id, name
      ) AS item_groups
        ON item_groups.user_id = items.user_id
        AND item_groups.name = items.name
      ON CONFLICT (item_id, store_id) DO NOTHING
    SQL

    # Delete the original availability rows belonging to non-surviving items
    # now that their store relationships belong to the surviving items.
    execute(<<~SQL.squish)
      DELETE FROM item_availabilities
      USING items,
            (
              SELECT user_id, name, MIN(id) AS item_id
              FROM items
              GROUP BY user_id, name
            ) AS item_groups
      WHERE item_availabilities.item_id = items.id
        AND item_groups.user_id = items.user_id
        AND item_groups.name = items.name
        AND items.id != item_groups.item_id
    SQL

    # Delete the non-surviving items after removing their availability rows.
    execute(<<~SQL.squish)
      DELETE FROM items
      USING (
        SELECT user_id, name, MIN(id) AS item_id
        FROM items
        GROUP BY user_id, name
      ) AS item_groups
      WHERE item_groups.user_id = items.user_id
        AND item_groups.name = items.name
        AND items.id != item_groups.item_id
    SQL
  end
end
