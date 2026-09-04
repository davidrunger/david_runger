class AllowDisabledStoreSectionConfigurationsToRetainSchemes < ActiveRecord::Migration[8.1]
  CONSTRAINT_NAME = 'store_section_configurations_scheme_matches_enabled_state'

  def up
    remove_check_constraint(:store_section_configurations, name: CONSTRAINT_NAME)
    add_check_constraint(
      :store_section_configurations,
      'NOT sectioning_enabled OR store_section_scheme_id IS NOT NULL',
      name: CONSTRAINT_NAME,
    )
  end

  def down
    remove_check_constraint(:store_section_configurations, name: CONSTRAINT_NAME)
    execute(<<~SQL.squish)
      DELETE FROM item_section_assignments
      USING store_section_configurations
      WHERE item_section_assignments.store_section_configuration_id = store_section_configurations.id
        AND NOT store_section_configurations.sectioning_enabled
    SQL
    execute(<<~SQL.squish)
      UPDATE store_section_configurations
      SET store_section_scheme_id = NULL
      WHERE NOT sectioning_enabled
    SQL
    add_check_constraint(
      :store_section_configurations,
      'sectioning_enabled = (store_section_scheme_id IS NOT NULL)',
      name: CONSTRAINT_NAME,
    )
  end
end
