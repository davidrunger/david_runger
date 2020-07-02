# frozen_string_literal: true

class AddSmsAllowanceToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column(
      :users,
      :sms_allowance,
      :float,
      null: false,
      default: 1.0,
      comment: 'Total cost in EUR of text messages that the user is allowed to accrue.',
    )
  end
end
