class EnforceCaseInsensitiveItemNames < ActiveRecord::Migration[8.1]
  def up
    remove_index(:items, name: 'index_items_on_user_id_and_name')

    combine_same_name_items

    add_index(
      :items,
      'user_id, LOWER(name)',
      name: 'index_items_on_user_id_and_lower_name',
      unique: true,
    )
  end

  def down
    remove_index(:items, name: 'index_items_on_user_id_and_lower_name')
    add_index(:items, %i[user_id name], unique: true)
  end

  private

  def combine_same_name_items
    # Keep the lowest-ID item in each case-insensitive user/name group, thereby
    # preserving its spelling, and give it the group's highest needed count.
    execute(<<~SQL.squish)
      WITH item_groups AS (
        SELECT user_id, LOWER(name) AS normalized_name, MIN(id) AS item_id, MAX(needed) AS needed
        FROM items
        GROUP BY user_id, LOWER(name)
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
        SELECT user_id, LOWER(name) AS normalized_name, MIN(id) AS item_id
        FROM items
        GROUP BY user_id, LOWER(name)
      ) AS item_groups
        ON item_groups.user_id = items.user_id
        AND item_groups.normalized_name = LOWER(items.name)
      ON CONFLICT (item_id, store_id) DO NOTHING
    SQL

    # Delete the original availability rows belonging to non-surviving items
    # now that their store relationships belong to the surviving items.
    execute(<<~SQL.squish)
      DELETE FROM item_availabilities
      USING items,
            (
              SELECT user_id, LOWER(name) AS normalized_name, MIN(id) AS item_id
              FROM items
              GROUP BY user_id, LOWER(name)
            ) AS item_groups
      WHERE item_availabilities.item_id = items.id
        AND item_groups.user_id = items.user_id
        AND item_groups.normalized_name = LOWER(items.name)
        AND items.id != item_groups.item_id
    SQL

    # Delete the non-surviving case-only item variants after removing their
    # availability rows.
    execute(<<~SQL.squish)
      DELETE FROM items
      USING (
        SELECT user_id, LOWER(name) AS normalized_name, MIN(id) AS item_id
        FROM items
        GROUP BY user_id, LOWER(name)
      ) AS item_groups
      WHERE item_groups.user_id = items.user_id
        AND item_groups.normalized_name = LOWER(items.name)
        AND items.id != item_groups.item_id
    SQL
  end
end
