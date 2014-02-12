Hbshollis::Application.routes.draw do
  root 'home#index'
  resources :authors, only: [:index, :show]
  resources :units, only: [:index, :show]
  resources :topics, only: [:index, :show]
  resource :stackview, only: [:show]
end
