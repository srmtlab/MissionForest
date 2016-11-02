Rails.application.routes.draw do
  root 'missions#index'
  devise_for :users
  resources :missions
end
