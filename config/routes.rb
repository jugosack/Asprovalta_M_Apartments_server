# Rails.application.routes.draw do
#   devise_for :users, controllers: {
#     sessions: 'users/sessions',
#     registrations: 'users/registrations'
#   }


 
#   # Non-nested routes
#   resources :users, except: [:destroy]
#   resources :rooms, except: [:destroy]
#   resources :reservations, except: [:destroy]

#   # Nested routes
#   resources :users, only: [] do
#     resources :reservations, only: [:index, :new, :create, :update]
#   end

#   resources :rooms, only: [] do
#     resources :reservations, only: [:index, :new, :create]
#     resources :room_daily_prices, only: [:index, :new, :create]
#   end

#   # Additional non-nested routes
#   resources :room_daily_prices, only: [:edit, :update, :destroy]

#   # Add any other custom routes you may need here
  


#   resources :rooms, only: [] do
#     collection do
#       post 'check_availability', to: 'rooms#check_availability'
#     end
#   end

#   resources :rooms do
#     member do
#       post 'block_dates'
#     end
#   end

#   resources :rooms do
#     member do
#       post :unblock_dates
#     end
#   end
  
#   delete 'reservations/:id', to: 'rooms#destroy_reservation', as: :destroy_reservation

#   root 'pages#home' # Change 'pages#home' to the desired controller and action for your application's home page
# end


Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }


 
  # Non-nested routes
  resources :users, except: [:destroy]
  resources :rooms, except: [:destroy]
  resources :reservations, except: [:destroy]

  # Nested routes
  resources :users, only: [] do
    resources :reservations, only: [:index, :new, :create, :update]
  end

  resources :rooms, only: [] do
    resources :reservations, only: [:index, :new, :create]
    resources :room_daily_prices, only: [:index, :new, :create]
  end

  # Additional non-nested routes
  resources :room_daily_prices, only: [:edit, :update, :destroy]

  # Add any other custom routes you may need here

   resources :rooms, only: [] do
    collection do
      post 'check_availability', to: 'rooms#check_availability'
    end
  end

  resources :rooms do
    member do
      post 'block_dates'
    end
  end

  resources :rooms do
    member do
      post :unblock_dates
    end
  end
  
  resources :users, only: [] do
    resources :rooms, only: [] do
      resources :reservations, only: [:create]
    end
  end
  
  # post '/users/:user_id/rooms/:room_id/reservations', to: 'reservations#create'


  delete 'reservations/:id', to: 'rooms#destroy_reservation', as: :destroy_reservation

  root 'pages#home' # Change 'pages#home' to the desired controller and action for your application's home page
end

