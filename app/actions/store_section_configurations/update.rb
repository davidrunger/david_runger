class StoreSectionConfigurations::Update < ApplicationAction
  requires :store_section_configuration, StoreSectionConfiguration
  requires :attributes, ActionController::Parameters

  def execute
    configuration_was_persisted = store_section_configuration.persisted?
    previous_scheme_id = store_section_configuration.store_section_scheme_id
    store_section_configuration.assign_attributes(attributes)

    StoreSectionConfiguration.transaction do
      store_section_configuration.save!
      if (
        configuration_was_persisted &&
          previous_scheme_id.present? &&
          previous_scheme_id != store_section_configuration.store_section_scheme_id
      )
        store_section_configuration.item_section_assignments.destroy_all
      end
    end
  end
end
