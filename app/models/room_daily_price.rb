class RoomDailyPrice < ApplicationRecord
  belongs_to :room
  def zero?
    return price == 0
  end
end
