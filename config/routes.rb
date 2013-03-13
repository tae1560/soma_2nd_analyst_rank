AnalystRank::Application.routes.draw do
  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
  resources :day_candles
  resources :stock_codes
  resources :recommendations
  resources :stock_firms
end