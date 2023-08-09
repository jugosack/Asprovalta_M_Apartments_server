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
    resources :reservations, only: [:index, :new, :create]
  end

  resources :rooms, only: [] do
    resources :reservations, only: [:index, :new, :create]
    resources :room_daily_prices, only: [:index, :new, :create]
  end

  # Additional non-nested routes
  resources :room_daily_prices, only: [:edit, :update, :destroy]

  # Add any other custom routes you may need here

  root 'pages#home' # Change 'pages#home' to the desired controller and action for your application's home page

end
