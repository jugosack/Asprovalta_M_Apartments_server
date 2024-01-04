class RemoveUserNameFromReservations < ActiveRecord::Migration[7.0]
  def change
    remove_column :reservations, :user_name, :string
  end
end
