class Api::DeletedItemRestorationsController < Api::BaseController
  def create
    item_version =
      PaperTrail::Version.where(item_type: Item.name, event: 'destroy').find(
        params.expect(:item_version_id),
      )
    authorize(item_version, :create?, policy_class: ReificationPolicy)

    item_availability_version_ids =
      params.
        expect(item_availability_version_ids: []).
        map { Integer(it, exception: false) }.
        uniq
    item_availability_versions =
      PaperTrail::Version.
        where(item_type: ItemAvailability.name, event: 'destroy').
        where(id: item_availability_version_ids).
        to_a
    if item_availability_versions.size != item_availability_version_ids.size
      raise(ActiveRecord::RecordNotFound)
    end

    item =
      DeletedItems::Restore.run!(
        item_availability_versions:,
        item_version:,
      ).item

    render_schema_json(item)
  end
end
