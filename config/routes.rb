Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  
  root to: "home#index"
  resources :home
  resources :customers do
    resources :deals
  end





end
