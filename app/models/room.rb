# class Room < ApplicationRecord
#   has_many :reservations
#   has_many :room_daily_prices

#   def self.available_rooms(start_date, end_date, capacity)
#     overlapping_reservations = Reservation.where("(start_date, end_date) OVERLAPS (?, ?)", start_date, end_date)
#     reserved_room_ids = overlapping_reservations.pluck(:room_id)

#     available_rooms = where.not(id: reserved_room_ids).where("capacity >= ?", capacity)

#     available_rooms
#   end

# end

class Room < ApplicationRecord
  has_many :reservations
  has_many :room_daily_prices

  attribute :blocked_dates, :json, default: [] # If using JSON field
  def self.available_rooms(start_date, end_date, capacity)
    overlapping_reservations = Reservation.where('(start_date, end_date) OVERLAPS (?, ?)', start_date, end_date)
    reserved_room_ids = overlapping_reservations.pluck(:room_id)

    available_rooms = where.not(id: reserved_room_ids).where('capacity >= ?', capacity)

    puts "Available rooms: #{available_rooms.pluck(:name)}"

    available_rooms
  end
end
