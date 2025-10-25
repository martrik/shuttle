class AddIndexToUsersRailwayApiKey < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :railway_api_key, unique: true
  end
end

