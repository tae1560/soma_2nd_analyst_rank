AnalystRank::Application.routes.draw do
  #authenticated :user do
  #  root :to => 'home#index'
  #end
  #root :to => "home#index"
  root :to => "stock_firms#index"
  devise_for :users
  resources :users
  resources :day_candles
  resources :stock_codes
  resources :recommendations
  resources :stock_firms
  resources :gcm_devices
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
end