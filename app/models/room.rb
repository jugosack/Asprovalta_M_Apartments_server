# class Room < ApplicationRecord
#     has_many :reservations
# end
class Room < ApplicationRecord
  has_many :reservations
  has_many :room_daily_prices

  def available?(start_date, end_date)
    # Check if there are any reservations that overlap with the given date range
    overlapping_reservations = reservations.where("(start_date, end_date) OVERLAPS (?, ?)", start_date, end_date)

    # If there are overlapping reservations, the room is not available
    overlapping_reservations.empty?
  end
end