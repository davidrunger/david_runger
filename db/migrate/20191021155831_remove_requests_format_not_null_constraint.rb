# frozen_string_literal: true

class RemoveRequestsFormatNotNullConstraint < ActiveRecord::Migration[6.0]
  def change
    change_column_null :requests, :format, true
  end
end
