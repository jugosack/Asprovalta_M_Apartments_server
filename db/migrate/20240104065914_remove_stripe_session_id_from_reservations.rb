class RemoveStripeSessionIdFromReservations < ActiveRecord::Migration[7.0]
  def change
    remove_column :reservations, :stripe_session_id
  end
end
