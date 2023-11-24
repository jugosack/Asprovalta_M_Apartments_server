class RoomDailyPrice < ApplicationRecord
  belongs_to :room
  def zero?
    price.zero?
  end
end
