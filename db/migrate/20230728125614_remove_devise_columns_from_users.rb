class RemoveDeviseColumnsFromUsers < ActiveRecord::Migration[7.0]
  def change
    
      remove_column :users, :email, :string
      # Add more remove_column lines for any other Devise-related columns you want to remove
  
  end
end
