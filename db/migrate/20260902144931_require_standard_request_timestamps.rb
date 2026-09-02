class RequireStandardRequestTimestamps < ActiveRecord::Migration[8.1]
  def up
    add_check_constraint(
      :requests,
      'created_at IS NOT NULL',
      name: 'requests_created_at_not_null',
      validate: false,
    )
    add_check_constraint(
      :requests,
      'updated_at IS NOT NULL',
      name: 'requests_updated_at_not_null',
      validate: false,
    )

    validate_check_constraint(:requests, name: 'requests_created_at_not_null')
    validate_check_constraint(:requests, name: 'requests_updated_at_not_null')

    change_column_null(:requests, :created_at, false)
    change_column_null(:requests, :updated_at, false)

    remove_check_constraint(:requests, name: 'requests_created_at_not_null')
    remove_check_constraint(:requests, name: 'requests_updated_at_not_null')

    change_column_null(:requests, :requested_at, true)
  end

  def down
    change_column_null(:requests, :created_at, true)
    change_column_null(:requests, :updated_at, true)

    # After this release creates `Request`s, copy `created_at` into `requested_at`
    # before rolling back.
    change_column_null(:requests, :requested_at, false)
  end
end
