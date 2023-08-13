# class Reservation < ApplicationRecord
#   belongs_to :room
#   belongs_to :user
# end

class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :room

  validate :no_date_overlap
  validate :start_date_cannot_be_in_the_past

  # Other model code...

  private

  def no_date_overlap
    existing_reservations = room.reservations.where.not(id: id)
    overlapping_reservations = existing_reservations.where(
      '(start_date, end_date) OVERLAPS (?, ?)', start_date, end_date
    )

    if overlapping_reservations.any?
      errors.add(:base, 'Reservation dates overlap with existing reservation')
    end
  end

  def start_date_cannot_be_in_the_past
    if start_date && start_date < Date.today
      errors.add(:start_date, 'Start date cannot be in the past')
    end
  end
end
