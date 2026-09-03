class CreateStoreSectionManagement < ActiveRecord::Migration[8.1]
  def change
    create_table :store_section_schemes do |t|
      t.references :user, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.timestamps
    end
    add_index(
      :store_section_schemes,
      'user_id, LOWER(name)',
      unique: true,
      name: 'index_store_section_schemes_on_user_id_and_name',
    )

    create_table :store_sections do |t|
      t.references(
        :store_section_scheme,
        null: false,
        index: false,
        foreign_key: { on_delete: :cascade },
      )
      t.string :name, null: false
      t.timestamps
    end
    add_index(
      :store_sections,
      'store_section_scheme_id, LOWER(name)',
      unique: true,
      name: 'index_store_sections_on_scheme_id_and_name',
    )

    create_table :store_section_configurations do |t|
      t.references :user, null: false, index: false, foreign_key: { on_delete: :cascade }
      t.references :store, null: false, foreign_key: { on_delete: :cascade }
      t.references :store_section_scheme, foreign_key: true
      t.boolean :sectioning_enabled, null: false, default: false
      t.timestamps
    end
    add_index(
      :store_section_configurations,
      %i[user_id store_id],
      unique: true,
    )
    add_check_constraint(
      :store_section_configurations,
      'sectioning_enabled = (store_section_scheme_id IS NOT NULL)',
      name: 'store_section_configurations_scheme_matches_enabled_state',
    )

    create_table :item_section_assignments do |t|
      t.references(
        :store_section_configuration,
        null: false,
        index: false,
        foreign_key: { on_delete: :cascade },
      )
      t.references :item_availability, null: false, foreign_key: { on_delete: :cascade }
      t.references :store_section, null: false, foreign_key: true
      t.timestamps
    end
    add_index(
      :item_section_assignments,
      %i[store_section_configuration_id item_availability_id],
      unique: true,
    )
  end
end
