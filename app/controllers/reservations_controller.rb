class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: %i[show update]

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      if @user == current_user
        @reservations = @user.reservations
        render json: @reservations
      else
        render json: { error: 'Access denied' }, status: :unauthorized
      end
    else
      @reservations = Reservation.all
      render json: @reservations
    end
  end

  def show
    render json: @reservation
  end

  def create
    @reservation = Reservation.new(reservation_params)

    # Access the user name from reservation_params
    user_name = reservation_params[:user_name]
    @reservation.user_name = user_name

    # Calculate the total price based on daily room prices
    room = Room.find(@reservation.room_id)
    start_date = @reservation.start_date
    end_date = @reservation.end_date
    daily_prices = room.room_daily_prices.where(date: start_date..end_date)

    if daily_prices.empty?
      render json: { error: 'No daily prices available for the specified date range' }, status: :unprocessable_entity
      return
    end

    num_nights = (end_date - start_date).to_i
    total_price = num_nights * daily_prices.sum(:price)
    @reservation.total_price = total_price

    if @reservation.save
      render json: @reservation, status: :created
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:room_id, :user_id, :start_date, :end_date, :num_nights, :total_price, :user_name)
  end
end
