class Api::StoresController < Api::BaseController
  before_action :set_store, only: %i[destroy update]

  def index
    authorize(Store)

    spouse = current_user.spouse

    render_schema_json({
      own_stores:
        StoreSerializer.new(
          current_user.stores.includes(
            { items: :item_availabilities },
            store_section_configurations: [
              { store_section_scheme: :store_sections },
              { item_section_assignments: :item_availability },
            ],
          ),
          params: { current_user: },
        ).as_json,
      spouse_stores:
        if spouse
          StoreSerializer.new(
            spouse.stores.where.not(private: true).includes(
              { items: :item_availabilities },
              store_section_configurations: [
                { store_section_scheme: :store_sections },
                { item_section_assignments: :item_availability },
              ],
            ),
            params: { current_user: },
          ).as_json
        else
          []
        end,
    })
  end

  def create
    authorize(Store)
    @store = current_user.stores.build(store_params.merge(viewed_at: Time.current))
    if @store.save
      render_schema_json(@store, status: :created)
    else
      render json: { errors: @store.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    authorize(@store)
    if @store.update(store_params)
      render_schema_json(@store)
    else
      render json: { errors: @store.errors.to_hash }, status: :unprocessable_content
    end
  end

  def destroy
    authorize(@store)
    Stores::Destroy.run!(store: @store)
    head(:no_content)
  end

  private

  def set_store
    @store =
      current_user.stores.includes(items: :item_availabilities).find_by(id: params['id'])
    if @store.nil?
      head(:not_found)
    end
  end

  def store_params
    params.
      expect(store: %i[name notes private viewed_at])
  end
end
