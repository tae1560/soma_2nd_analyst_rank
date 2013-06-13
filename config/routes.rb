AnalystRank::Application.routes.draw do
  #authenticated :user do
  #  root :to => 'home#index'
  #end
  root :to => "home#index"
  #root :to => "stock_firms#index"
  devise_for :users, :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks"
  }
  devise_for :users
  resources :users
  resources :day_candles
  resources :stock_codes
  resources :recommendations
  resources :stock_firms
  resources :gcm_devices
  resources :home
  resources :app_info
  resources :push_messages_on_devices
  resources :user_subscribe_stock_firms
  namespace :api do
    namespace :v1 do
      resources :signals
    end
  end


end