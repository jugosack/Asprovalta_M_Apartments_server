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

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def check_availability
    start_date = Date.strptime(params[:start_date], '%Y-%m-%d')
    end_date = Date.strptime(params[:end_date], '%Y-%m-%d')
    capacity = params[:capacity].to_i

    today = Date.today
    if end_date < today
      render json: { error: 'Invalid date range. End date must be today or in the future.' },
             status: :unprocessable_entity
      return
    end

    all_rooms = Room.all
    available_dates_per_room = {}

    (start_date..end_date).each do |date|
      next if date < today # Skip dates before today

      all_rooms.each do |room|
        blocked_dates = room.blocked_dates.map(&:to_date)
        reserved_date_ranges = Reservation.where('room_id = ? AND (start_date, end_date) OVERLAPS (?, ?)', room.id,
                                                 date, date)
        # rubocop:disable Style/Next
        if room.capacity >= capacity && !(blocked_dates.include?(date) || reserved_date_ranges.present?)
          daily_price = RoomDailyPrice.find_by(room_id: room.id, date: date)&.price

          if daily_price.present? && daily_price.positive?
            available_dates_per_room[room.id] ||= {
              name: room.name,
              available_dates: []
            }

            available_dates_per_room[room.id][:available_dates] << {
              date: date.to_s,
              price: daily_price
            }
          end
        end
        # rubocop:enable Style/Next
      end
    end

    simplified_output = available_dates_per_room.transform_values do |room_data|
      {
        name: room_data[:name],
        available_dates: room_data[:available_dates]
      }
    end

    render json: {
      start_date: start_date.to_s,
      end_date: end_date.to_s,
      available_dates_per_room: simplified_output
    }
  rescue ArgumentError
    render json: { error: 'Invalid date format. Please provide dates in the format YYYY-MM-DD.' },
           status: :unprocessable_entity
  end

  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity

  def block_dates
    @room = Room.find(params[:id])
    blocked_date = begin
      Date.parse(params[:blocked_date])
    rescue StandardError
      nil
    end

    if blocked_date
      @room.blocked_dates << blocked_date
      @room.save
      render json: { message: 'Date blocked successfully' }
    else
      render json: { error: 'Invalid date format. Please provide a date in the format YYYY-MM-DD.' },
             status: :unprocessable_entity
    end
  end

  def unblock_dates
    @room = Room.find(params[:id])
    unblocked_date = begin
      Date.parse(params[:unblocked_date])
    rescue StandardError
      nil
    end

    if unblocked_date
      @room.blocked_dates.delete(unblocked_date.to_s)
      @room.save
      render json: { message: 'Date unblocked successfully' }
    else
      render json: { error: 'Invalid date format. Please provide a date in the format YYYY-MM-DD.' },
             status: :unprocessable_entity
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
      render json: { message: 'Reservation deleted successfully' }
    else
      render json: { error: 'Failed to delete reservation' }, status: :unprocessable_entity
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
