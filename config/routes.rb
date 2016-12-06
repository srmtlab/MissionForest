Rails.application.routes.draw do
  root 'missions#index'
  devise_for :users
  resources :missions
  resources :tasks

  get 'tasks/:id/new' => 'tasks#new_child', as: :tasks_child_new
  post 'tasks/:id/create' => 'tasks#create_child', as: :tasks_child_create
end
