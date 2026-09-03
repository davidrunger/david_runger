class Api::Items::SectionAssignmentsController < Api::BaseController
  before_action :set_store
  before_action :set_item_availability
  before_action :set_store_section_configuration

  def update
    store_section =
      @store_section_configuration.store_section_scheme.store_sections.find(
        section_assignment_params.fetch(:store_section_id),
      )
    assignment =
      @store_section_configuration.item_section_assignments.find_or_initialize_by(
        item_availability: @item_availability,
      )
    assignment.store_section = store_section
    assignment.save!

    head(:no_content)
  end

  def destroy
    @store_section_configuration.item_section_assignments.find_by!(
      item_availability: @item_availability,
    ).destroy!

    head(:no_content)
  end

  private

  def set_store
    @store = policy_scope(Store).find(params.expect(:store_id))
    authorize(@store, :show?)
  end

  def set_item_availability
    @item_availability = @store.item_availabilities.find_by!(item_id: params.expect(:item_id))
  end

  def set_store_section_configuration
    @store_section_configuration =
      current_user.store_section_configurations.where(sectioning_enabled: true).find_by(
        store: @store,
      )
    if @store_section_configuration
      authorize(@store_section_configuration)
    else
      head(:not_found)
    end
  end

  def section_assignment_params
    params.expect(section_assignment: [:store_section_id])
  end
end
