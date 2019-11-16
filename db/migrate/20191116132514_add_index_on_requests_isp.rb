# frozen_string_literal: true

class AddIndexOnRequestsIsp < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :requests, :isp, algorithm: :concurrently
  end
end
