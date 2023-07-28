class RoomDailyPricesController < ApplicationController
  before_action :set_room_daily_price, only: %i[show update destroy]

  def index
    @room_daily_prices = RoomDailyPrice.all
    render json: @room_daily_prices
  end

  def show
    render json: @room_daily_price
  end

  def create
    @room_daily_price = RoomDailyPrice.new(room_daily_price_params)
    if @room_daily_price.save
      render json: @room_daily_price, status: :created
    else
      render json: @room_daily_price.errors, status: :unprocessable_entity
    end
  end

  def update
    if @room_daily_price.update(room_daily_price_params)
      render json: @room_daily_price
    else
      render json: @room_daily_price.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @room_daily_price.destroy
    head :no_content
  end

  private

  def set_room_daily_price
    @room_daily_price = RoomDailyPrice.find(params[:id])
  end

  def room_daily_price_params
    params.require(:room_daily_price).permit(:room_id, :date, :price)
  end
end
