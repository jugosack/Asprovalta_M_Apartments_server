class CreateRoomDailyPrices < ActiveRecord::Migration[7.0]
  def change
    create_table :room_daily_prices do |t|
      t.references :room, null: false, foreign_key: true
      t.date :date
      t.float :price

      t.timestamps
    end
  end
end
