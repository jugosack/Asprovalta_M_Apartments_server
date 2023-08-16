# class RoomsController < ApplicationController
  

#   protect_from_forgery with: :null_session
#   skip_before_action :verify_authenticity_token
#   before_action :authenticate_user!, except: [:check_availability]
#   before_action :set_room, only: %i[show update]
  
  

#   def index
#     @rooms = Room.all
#     render json: @rooms
#   end

#   def show
#     render json: @room
#   end

#   def check_availability
#     begin
#       start_date = Date.parse(params[:start_date])
#       end_date = Date.parse(params[:end_date])
#       capacity = params[:capacity].to_i

#       if start_date >= end_date
#         render json: { error: "Invalid date range. Start date must be before end date." }, status: :unprocessable_entity
#         return
#       end

#       available_rooms = Room.available_rooms(start_date, end_date, capacity)

#       if available_rooms.empty?
#         render json: { start_date: start_date.to_s, end_date: end_date.to_s, message: "No available rooms for the selected date range. Please check other dates." }
#       else
#         render json: { start_date: start_date.to_s, end_date: end_date.to_s, available_rooms: available_rooms }
#       end
#     rescue ArgumentError
#       render json: { error: "Invalid date format. Please provide dates in the format YYYY-MM-DD." }, status: :unprocessable_entity
#     end
#   end


#   def create
#     @room = Room.new(room_params)
#     if @room.save
#       render json: @room, status: :created
#     else
#       render json: @room.errors, status: :unprocessable_entity
#     end
#   end

#   def update
#     if @room.update(room_params)
#       render json: @room
#     else
#       render json: @room.errors, status: :unprocessable_entity
#     end
#   end

#   def destroy_reservation
#     reservation = Reservation.find(params[:id])
#     if reservation.destroy
#       render json: { message: "Reservation deleted successfully" }
#     else
#       render json: { error: "Failed to delete reservation" }, status: :unprocessable_entity
#     end
#   end

#   private

#   def set_room
#     @room = Room.find(params[:id])
#   end

#   def room_params
#     params.require(:room).permit(:name, :capacity)
#   end
# end

class RoomsController < ApplicationController
  

  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, except: [:check_availability]
  before_action :set_room, only: %i[show update]
  
  

  def index
    @rooms = Room.all
    render json: @rooms
  end

  def show
    render json: @room
  end

def check_availability
  begin
    start_date = Date.strptime(params[:start_date], "%Y-%m-%d")
    end_date = Date.strptime(params[:end_date], "%Y-%m-%d")
    capacity = params[:capacity].to_i

    if start_date >= end_date
      render json: { error: "Invalid date range. Start date must be before end date." }, status: :unprocessable_entity
      return
    end

    all_rooms = Room.all
    available_dates_per_room = {}

    (start_date..end_date).each do |date|
      all_rooms.each do |room|
        blocked_dates = room.blocked_dates.map(&:to_date)
        reserved_date_ranges = Reservation.where("room_id = ? AND (start_date, end_date) OVERLAPS (?, ?)", room.id, date, date)

        if room.capacity >= capacity && !(blocked_dates.include?(date) || reserved_date_ranges.present?)
          available_dates_per_room[room.name] ||= []
          available_dates_per_room[room.name] << date.to_s
        end
      end
    end

    render json: {
      start_date: start_date.to_s,
      end_date: end_date.to_s,
      available_dates_per_room: available_dates_per_room
    }
  rescue ArgumentError
    render json: { error: "Invalid date format. Please provide dates in the format YYYY-MM-DD." }, status: :unprocessable_entity
  end
end


  
  def block_dates
    @room = Room.find(params[:id])
    blocked_date = Date.parse(params[:blocked_date]) rescue nil
  
    if blocked_date
      @room.blocked_dates << blocked_date
      @room.save
      render json: { message: "Date blocked successfully" }
    else
      render json: { error: "Invalid date format. Please provide a date in the format YYYY-MM-DD." }, status: :unprocessable_entity
    end
  end

  def unblock_dates
    @room = Room.find(params[:id])
    unblocked_date = Date.parse(params[:unblocked_date]) rescue nil

    if unblocked_date
      @room.blocked_dates.delete(unblocked_date.to_s)
      @room.save
      render json: { message: "Date unblocked successfully" }
    else
      render json: { error: "Invalid date format. Please provide a date in the format YYYY-MM-DD." }, status: :unprocessable_entity
    end
  end
  
  def create
    @room = Room.new(room_params)
    if @room.save
      render json: @room, status: :created
    else
      render json: @room.errors, status: :unprocessable_entity
    end
  end

  def update
    if @room.update(room_params)
      render json: @room
    else
      render json: @room.errors, status: :unprocessable_entity
    end
  end

  def destroy_reservation
    reservation = Reservation.find(params[:id])
    if reservation.destroy
      render json: { message: "Reservation deleted successfully" }
    else
      render json: { error: "Failed to delete reservation" }, status: :unprocessable_entity
    end
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :capacity)
  end
end