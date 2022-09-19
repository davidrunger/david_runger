# frozen_string_literal: true

class SupportEmotionalNeedNameValidations < ActiveRecord::Migration[7.0]
  def change
    change_column_null :emotional_needs, :name, false

    remove_index :emotional_needs, :marriage_id
    add_index :emotional_needs, %i[marriage_id name], unique: true
  end
end
