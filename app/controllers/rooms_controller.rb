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

#   def check_availability IRB
#   start_date = Date.parse(params[:start_date])
#   end_date = Date.parse(params[:end_date])
#   available_rooms = []

#   Room.find_each do |room|
#     # Check if the room is available for the given date range
#     if room.available?(start_date, end_date)
#       available_rooms << room
#     end
#   end

#   Rails.logger.info("Available Rooms: #{available_rooms.inspect}") # Debug output

#   render json: available_rooms
# end

# def check_availability JSON
#   # Get the start and end dates from the query string
#   start_date = params[:start_date]
#   end_date = params[:end_date]

#   # Check if the rooms are available for the given date range
#   available_rooms = []

#   Room.find_each do |room|
#     # Check if the room is available for the given date range
#     if room.available?(start_date, end_date)
#       available_rooms << room
#     end
#   end

#   # Render the available rooms
#   render json: available_rooms
# end

# def check_availability
#   # Get the start and end dates from the query string
#   start_date = params[:start_date]
#   end_date = params[:end_date]

#   # Check if the rooms are available and have a price for the given date range
#   available_rooms = []

#   Room.find_each do |room|
#     # Check if the room is available for the given date range
#     # and has a price associated with it
#     if room.available?(start_date, end_date) && room.room_daily_prices.exists?
#       available_rooms << room
#     end
#   end

#   # Render the available rooms
#   render json: available_rooms
# end

def check_availability
  # Get the start and end dates from the query string
  start_date = params[:start_date]
  end_date = params[:end_date]
  capacity = params[:capacity]

  # Check if the rooms are available, have a price, and meet the capacity requirement
  available_rooms = []

  Room.find_each do |room|
    # Check if the room is available for the given date range,
    # has a price associated with it, and meets the capacity requirement
    if room.available?(start_date, end_date) && room.room_daily_prices.exists? && room.capacity >= capacity.to_i
      available_rooms << room
    end
  end

  # Render the available rooms
  render json: available_rooms
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

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :capacity)
  end
end