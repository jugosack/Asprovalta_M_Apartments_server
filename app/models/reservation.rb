class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validate :no_date_overlap
  validate :start_date_cannot_be_in_the_past

  validate :no_nil_or_blank_or_zero_room_prices

  before_save :calculate_total_price

  validate :no_blocked_dates

  private

  # def no_date_overlap
  #   existing_reservations = room.reservations.where.not(id: id)
  #   overlapping_reservations = existing_reservations.where(
  #     '(start_date, end_date) OVERLAPS (?, ?)', start_date, end_date
  #   )

  #   return unless overlapping_reservations.any?

  #   errors.add(:base, 'Reservation dates overlap with existing reservation')
  # end

  ############################################################################
  def no_date_overlap
    return unless room.present? # Check if the room association is present
  
    existing_reservations = room.reservations.where.not(id: id)
    overlapping_reservations = existing_reservations.where(
      '(start_date, end_date) OVERLAPS (?, ?)', start_date, end_date
    )
  
    return unless overlapping_reservations.any?
  
    errors.add(:base, 'Reservation dates overlap with existing reservation')
  end
  ###############################################################################

  def start_date_cannot_be_in_the_past
    return unless start_date && start_date < Date.today

    errors.add(:start_date, 'Start date cannot be in the past')
  end

  # def no_nil_or_blank_or_zero_room_prices
  #   daily_prices = room.room_daily_prices.where(date: start_date..(end_date - 1.day))

  #   if daily_prices.size != (end_date - start_date).to_i
  #     errors.add(:base, 'Not all dates have valid room prices available')
  #   elsif daily_prices.any? { |price| price.nil? || price.zero? }
  #     errors.add(:base, 'No valid room prices available for the specified date range')
  #   end
  # end

  def no_nil_or_blank_or_zero_room_prices
    return unless @room
  
    daily_prices = @room.room_daily_prices&.where(date: start_date..(end_date - 1.day))
  
    if daily_prices.blank? || daily_prices.any? { |price| price.nil? || price.zero? }
      errors.add(:base, 'No valid room prices available for the specified date range')
    end
  end
  

  def calculate_total_price
    puts 'Calculating total price...'

    daily_prices = room.room_daily_prices.where(date: start_date..end_date).pluck(:price)

    if daily_prices.any?(&:nil?) || daily_prices.all?(&:zero?)
      errors.add(:base, 'No valid daily prices available for the specified date range')
      return false
    end

    daily_prices.compact! # Remove nil values from the array
    average_daily_price = daily_prices.sum / daily_prices.size.to_f

    num_nights = (end_date - start_date).to_i # Add 1 to include the end date
    self.num_nights = num_nights
    self.total_price = num_nights * average_daily_price

    puts "Total price calculated: #{total_price}"
  end

  # def no_blocked_dates
  #   blocked_dates = room.blocked_dates.map(&:to_date)

  #   return unless blocked_dates.any? { |date| date >= start_date && date < end_date }

  #   errors.add(:base, 'Reservation dates include blocked dates')
  # end

  def no_blocked_dates
    return unless room.present?
  
    blocked_dates = room.blocked_dates.map(&:to_date)
  
    return unless blocked_dates.any? { |date| date >= start_date && date < end_date }
  
    errors.add(:base, 'Reservation dates include blocked dates')
  end
  
end
