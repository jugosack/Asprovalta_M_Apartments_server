require 'stripe'

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

  # def create
  #   @reservation = Reservation.new(reservation_params)
  #   @reservation.user = current_user


  #   # Calculate the total price based on daily room prices
  #   room = Room.find(@reservation.room_id)
  #   start_date = @reservation.start_date
  #   end_date = @reservation.end_date
  #   daily_prices = room.room_daily_prices.where(date: start_date..end_date)

  #   if daily_prices.empty?
  #     render json: { error: 'No daily prices available for the specified date range' }, status: :unprocessable_entity
  #     return
  #   end

  #   num_nights = (end_date - start_date).to_i
  #   total_price = num_nights * daily_prices.sum(:price)
  #   @reservation.total_price = total_price

  #   if @reservation.save
  #     render json: @reservation, status: :created
  #   else
  #     render json: @reservation.errors, status: :unprocessable_entity
  #   end
  # end

  


  def create
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user
    
    # Fetch room_id from the URL parameters
    room_id = params[:room_id]
    @room = Room.includes(:room_daily_prices).find(room_id)  # Include associated room_daily_prices
  
    # Add logging for debugging
    Rails.logger.debug("Room ID: #{room_id}, Room: #{@room.inspect}")

    # Set the room association
  @reservation.room = @room
  
    # Calculate the total price based on daily room prices
    start_date = @reservation.start_date
    end_date = @reservation.end_date
    daily_prices = @room.room_daily_prices.where(date: start_date..end_date)
    
    if daily_prices.empty?
      render json: { error: 'No daily prices available for the specified date range' }, status: :unprocessable_entity
      return
    end
    
    num_nights = (end_date - start_date).to_i
    total_price = num_nights * daily_prices.sum(:price)
    @reservation.total_price = total_price
    
    if @reservation.save
      render json: {
        reservation: @reservation.attributes.merge(user_name: current_user.name, room_name: @room.name),
      }, status: :created
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end
  
  
  

  
###########################################################################################################################
# def create
#   @reservation = Reservation.new(reservation_params)
#   @reservation.user = current_user

#   room = Room.find(@reservation.room_id)
#   start_date = @reservation.start_date
#   end_date = @reservation.end_date
#   daily_prices = room.room_daily_prices.where(date: start_date..end_date)

#   if daily_prices.empty?
#     render json: { error: 'No daily prices available for the specified date range' }, status: :unprocessable_entity
#     return
#   end

#   num_nights = (end_date - start_date).to_i
#   total_price = num_nights * daily_prices.sum(:price)
#   @reservation.total_price = total_price

#   begin
#     Stripe.api_key = ENV['STRIPE_API_KEY']

#     # Create a Price object in Stripe
#     price = Stripe::Price.create(
#       unit_amount: (total_price * 100).to_i,
#       currency: 'eur',
#       product_data: {
#         name: 'Reservation Fee',
#       },
#     )

#     session = Stripe::Checkout::Session.create(
#       payment_method_types: ['card'],
#       line_items: [
#         {
#           price: price.id,  # Use the ID of the created Price object
#           quantity: 1,
#         },
#       ],
#       mode: 'payment',  # Set the mode to 'payment'
#       success_url: reservations_url, # Change to the appropriate success URL
#       cancel_url: reservations_url,
#     )

#     # Update the reservation with the Stripe session ID
#     @reservation.stripe_session_id = session.id
#   rescue Stripe::StripeError => e
#     render json: { error: e.message }, status: :unprocessable_entity
#     return
#   end

#   # Do not save the reservation to the database at this point

#   # Render the Stripe session ID and reservation details in the JSON response
#   render json: {
#     stripe_session_id: session.id,
#     reservation: @reservation.as_json(include: { user: { only: [:id, :name] } })
#   }, status: :created
# end


###########################################################################################################################
  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:room_id, :user_id, :start_date, :end_date, :num_nights, :total_price, :user_name)
  end
end
