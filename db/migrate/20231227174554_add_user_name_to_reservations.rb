class AddUserNameToReservations < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :user_name, :string
  end
end
