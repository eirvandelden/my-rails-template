# Routes configuration

route 'root "home#index"'

route <<~RUBY
  namespace :admin do
    resources :users, except: [:new, :create]
  end
RUBY

route 'resource :session, only: [:new, :create, :destroy]'
route 'resource :preferences, only: [:edit, :update]'
