class ChangeTimeseriesMeasurementsToJsonb < ActiveRecord::Migration[8.0]
  def up
    # Change column type from json to jsonb
    change_column :timeseries, :measurements, 'jsonb USING measurements::jsonb'
  end

  def down
    # Rollback from jsonb to json
    change_column :timeseries, :measurements, 'json USING measurements::json'
  end
end
