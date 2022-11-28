Rails.application.routes.draw do
  devise_for :users
  
  root to: "home#index"
  resources :home
  resources :customers do
    resources :deals
  end
  



end
