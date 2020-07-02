# frozen_string_literal: true

class DropTemplates < ActiveRecord::Migration[5.1]
  def change
    drop_table :templates
  end
end
