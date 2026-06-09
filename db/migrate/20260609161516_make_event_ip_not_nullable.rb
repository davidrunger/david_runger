class MakeEventIpNotNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :events, :ip, false
  end
end
