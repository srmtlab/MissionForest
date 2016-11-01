Rails.application.routes.draw do
  root 'missions#index'
  devise_for :users
  resources :users
  resources :missions
end
