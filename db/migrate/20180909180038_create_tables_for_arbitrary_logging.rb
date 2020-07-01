# frozen_string_literal: true

require Rails.root.join('db/datamigrate/convert_weight_logs_to_general_logs')

class CreateTablesForArbitraryLogging < ActiveRecord::Migration[5.2]
  def change
    ##################################
    # create `logs`
    ##################################
    create_table :logs do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :logs, %i[user_id name], unique: true

    ##################################
    # create `log_entries`
    ##################################
    create_table :log_entries do |t|
      t.references :log, null: false, foreign_key: true
      t.jsonb :data, null: false

      t.timestamps
    end

    ##################################
    # create `log_inputs
    ##################################
    create_table :log_inputs do |t|
      t.references :log, null: false, foreign_key: true, index: false
      t.string :type, null: false
      t.string :label, null: false
      t.integer :index, null: false, default: 0

      t.timestamps
    end
    add_index :log_inputs, %i[log_id index], unique: true

    ##################################
    # migrate old `weight_logs` to new model
    ##################################
    convert_weight_logs_to_general_logs

    ##################################
    # drop `weight_logs`
    ##################################
    drop_table :weight_logs
  end
end
