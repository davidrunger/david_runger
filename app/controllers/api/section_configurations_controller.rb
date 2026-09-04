class Api::SectionConfigurationsController < Api::BaseController
  before_action :set_store

  def update
    @store_section_configuration =
      current_user.store_section_configurations.find_or_initialize_by(store: @store)
    authorize(@store_section_configuration)

    StoreSectionConfigurations::Update.run!(
      store_section_configuration: @store_section_configuration,
      attributes: section_configuration_params,
    )
    head(:no_content)
  rescue ActiveRecord::RecordInvalid
    render(
      json: { errors: @store_section_configuration.errors.full_messages },
      status: :unprocessable_content,
    )
  end

  private

  def set_store
    @store = policy_scope(Store).find(params.expect(:store_id))
    authorize(@store, :show?)
  end

  def section_configuration_params
    params.expect(section_configuration: %i[sectioning_enabled store_section_scheme_id])
  end
end
