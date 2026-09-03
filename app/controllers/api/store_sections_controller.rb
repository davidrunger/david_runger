class Api::StoreSectionsController < Api::BaseController
  before_action :set_store_section_scheme
  before_action :set_store_section, only: %i[destroy update]

  def create
    @store_section = @store_section_scheme.store_sections.build(store_section_params)
    authorize(@store_section_scheme)
    if @store_section.save
      head(:no_content)
    else
      render json: { errors: @store_section.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    authorize(@store_section_scheme)
    if @store_section.update(store_section_params)
      head(:no_content)
    else
      render json: { errors: @store_section.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    authorize(@store_section_scheme)
    @store_section.destroy!
    head(:no_content)
  end

  private

  def set_store_section_scheme
    @store_section_scheme = policy_scope(StoreSectionScheme).find(
      params.expect(:store_section_scheme_id),
    )
  end

  def set_store_section
    @store_section = @store_section_scheme.store_sections.find(params.expect(:id))
  end

  def store_section_params
    params.expect(store_section: [:name])
  end
end
