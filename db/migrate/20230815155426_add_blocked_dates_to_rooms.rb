class AddBlockedDatesToRooms < ActiveRecord::Migration[7.0]
  def change
    add_column :rooms, :blocked_dates, :json, default: []
  end
end
