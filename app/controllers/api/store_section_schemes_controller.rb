class Api::StoreSectionSchemesController < Api::BaseController
  before_action :set_store_section_scheme, only: %i[update]

  def index
    authorize(StoreSectionScheme)
    render_schema_json({
      store_section_schemes:
        StoreSectionSchemeSerializer.new(
          policy_scope(StoreSectionScheme).includes(:store_sections),
        ).as_json,
    })
  end

  def create
    @store_section_scheme = current_user.store_section_schemes.build(store_section_scheme_params)
    authorize(@store_section_scheme)
    if @store_section_scheme.save
      head(:no_content)
    else
      render(
        json: { errors: @store_section_scheme.errors.full_messages },
        status: :unprocessable_content,
      )
    end
  end

  def update
    authorize(@store_section_scheme)
    if @store_section_scheme.update(store_section_scheme_params)
      head(:no_content)
    else
      render(
        json: { errors: @store_section_scheme.errors.full_messages },
        status: :unprocessable_content,
      )
    end
  end

  private

  def set_store_section_scheme
    @store_section_scheme = policy_scope(StoreSectionScheme).find(params.expect(:id))
  end

  def store_section_scheme_params
    params.expect(store_section_scheme: [:name])
  end
end
