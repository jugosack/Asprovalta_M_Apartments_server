class AddStripeSessionIdToReservations < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :stripe_session_id, :string
  end
end
