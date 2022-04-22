# frozen_string_literal: true

class DropSmsAllowanceFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :sms_allowance, :float
  end
end
