class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: %i[show update]

  # def index
  #   @reservations = Reservation.all

  #   @user = User.find(params[:user_id])  # Find the user by user_id parameter
  #   @reservations = @user.reservations   # Fetch reservations for the specific user

  #   render json: @reservations
  # end

  # def index
  #   if params[:user_id]
  #     @user = User.find(params[:user_id])
  #     @reservations = @user.reservations
  #   else
  #     @reservations = Reservation.all
  #   end
  #   render json: @reservations
  # end

  def index
    if params[:user_id]
      @user = User.find(params[:user_id])
      if @user == current_user
        @reservations = @user.reservations
        render json: @reservations
      else
        render json: { error: "Access denied" }, status: :unauthorized
      end
    else
      @reservations = Reservation.all
      render json: @reservations
    end
  end

  def show
    render json: @reservation
  end

  # def create
  #   @reservation = Reservation.new(reservation_params)
  #   if @reservation.save
  #     render json: @reservation, status: :created
  #   else
  #     render json: @reservation.errors, status: :unprocessable_entity
  #   end
  # end

  # def create
  #   @reservation = Reservation.new(reservation_params)

  #   # Calculate total price based on daily room prices
  #   daily_prices = RoomDailyPrice.where(room_id: @reservation.room_id, date: @reservation.start_date..@reservation.end_date)
  #   @reservation.total_price = daily_prices.sum(:price)

  #   if @reservation.save
  #     render json: @reservation, status: :created
  #   else
  #     render json: @reservation.errors, status: :unprocessable_entity
  #   end
  # end

  # def update
  #   if @reservation.update(reservation_params)
  #     render json: @reservation
  #   else
  #     render json: @reservation.errors, status: :unprocessable_entity
  #   end
  # end

  def create
    @reservation = Reservation.new(reservation_params)

    # Calculate the total price based on daily room prices
    room = Room.find(@reservation.room_id)
    start_date = @reservation.start_date
    end_date = @reservation.end_date
    daily_prices = room.room_daily_prices.where(date: start_date..end_date)

    if daily_prices.empty?
      render json: { error: "No daily prices available for the specified date range" }, status: :unprocessable_entity
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
    params.require(:reservation).permit(:room_id, :user_id, :start_date, :end_date, :num_nights, :total_price)
  end
end
