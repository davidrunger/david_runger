class Api::SectionConfigurationsController < Api::BaseController
  before_action :set_store

  def create
    @store_section_configuration = current_user.store_section_configurations.build(
      section_configuration_params.merge(store: @store),
    )
    authorize(@store_section_configuration)
    persist_configuration
  end

  def update
    @store_section_configuration =
      current_user.store_section_configurations.find_or_initialize_by(store: @store)
    authorize(@store_section_configuration)
    persist_configuration
  end

  private

  def set_store
    @store = policy_scope(Store).find(params.expect(:store_id))
    authorize(@store, :show?)
  end

  def persist_configuration
    previous_scheme_id = @store_section_configuration.store_section_scheme_id
    @store_section_configuration.assign_attributes(section_configuration_params)

    StoreSectionConfiguration.transaction do
      @store_section_configuration.save!
      if previous_scheme_id != @store_section_configuration.store_section_scheme_id
        @store_section_configuration.item_section_assignments.destroy_all
      end
    end

    head(:no_content)
  rescue ActiveRecord::RecordInvalid
    render(
      json: { errors: @store_section_configuration.errors.full_messages },
      status: :unprocessable_content,
    )
  end

  def section_configuration_params
    params.expect(section_configuration: %i[sectioning_enabled store_section_scheme_id])
  end
end
