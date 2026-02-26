# Routes configuration

route 'root "home#index"'

route <<~RUBY
  namespace :admin do
    root "dashboard#index"
    resources :users
    resources :dashboard, only: [:index]
  end
RUBY

route 'resource :session, only: [:new, :create, :destroy]'
route 'resource :preferences, only: [:edit, :update]'
