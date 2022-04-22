# frozen_string_literal: true

class DropPhoneFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :phone, :string
  end
end
