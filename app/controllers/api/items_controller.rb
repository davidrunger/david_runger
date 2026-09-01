class Api::ItemsController < Api::BaseController
  before_action :set_item, only: %i[destroy update]

  def create
    authorize(Item)
    store = policy_scope(Store).find_by(id: params.expect(:store_id))

    if store.nil?
      head(:not_found)
    else
      item_name = item_params[:name].to_s.squish
      @item = store.user.items.with_name(item_name).first_or_initialize(name: item_name)
      if @item.persisted? && @item.stores.include?(store)
        @item.errors.add(:name, :taken)
        render json: { errors: @item.errors.full_messages }, status: :unprocessable_content
      elsif add_item_to_store(store)
        render_schema_json(@item, status: :created)
      else
        render json: { errors: @item.errors.full_messages }, status: :unprocessable_content
      end
    end
  end

  def update
    if item_params.key?(:store_ids)
      authorize(@item, :manage_availabilities?)
      update_availabilities
    else
      authorize(@item)
      update_item
    end
  end

  def destroy
    authorize(@item)

    item_availability_ids = @item.item_availabilities.ids
    @item.destroy!
    item_availability_version_ids =
      PaperTrail::Version.
        where(
          item_id: item_availability_ids,
          item_type: ItemAvailability.name,
        ).
        destroys.
        group(:item_id).
        maximum(:id).
        values.
        sort

    render_schema_json({
      restore_item_path:
        api_deleted_item_restorations_path(
          item_availability_version_ids:,
          item_version_id: @item.versions.destroys.last!.id,
        ),
    })
  end

  private

  def add_item_to_store(store)
    update_succeeded =
      Item.transaction do
        @item.stores << store
        if @item.persisted?
          @item.updated_at = Time.current
        end

        if @item.save
          true
        else
          raise(ActiveRecord::Rollback)
        end
      end

    !!update_succeeded
  end

  def item_params
    params.expect(item: [:name, :needed, { store_ids: [] }])
  end

  def set_item
    @item = policy_scope(Item).find_by(id: params['id'])

    if @item.nil?
      head(:not_found)
    end
  end

  def update_availabilities
    store_ids = item_params[:store_ids].map { Integer(it, exception: false) }.uniq
    stores = @item.user.stores.where(id: store_ids).to_a

    if stores.size != store_ids.size
      @item.errors.add(:stores, 'contain an invalid store')
      render json: { errors: @item.errors.full_messages }, status: :unprocessable_content
    elsif update_item_availabilities(stores)
      render_schema_json(@item)
    else
      render_item_errors
    end
  end

  def update_item
    if @item.update(item_params)
      render_schema_json(@item)
    else
      render_item_errors
    end
  end

  def render_item_errors
    error_response = { errors: @item.errors.full_messages }
    if @item.errors.of_kind?(:name, :taken)
      error_response[:name_conflict] = true
      if policy(@item).merge?
        merge_target =
          @item.user.items.
            includes(:item_availabilities).
            where.not(id: @item).
            with_name(@item.name).
            first
        if merge_target && policy(merge_target).merge?
          error_response[:merge_target] = ItemSerializer.new(merge_target)
        end
      end
    end

    render json: error_response, status: :unprocessable_content
  end

  def update_item_availabilities(stores)
    update_succeeded =
      Item.transaction do
        @item.stores = stores
        @item.updated_at = Time.current

        if @item.save
          true
        else
          raise(ActiveRecord::Rollback)
        end
      end

    !!update_succeeded
  end
end
