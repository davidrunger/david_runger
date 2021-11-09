# frozen_string_literal: true

class AddSomeForeignKeyNotNullConstraints < ActiveRecord::Migration[6.1]
  def change
    change_column_null :sms_records, :user_id, false
    change_column_null :stores, :user_id, false
  end
end
