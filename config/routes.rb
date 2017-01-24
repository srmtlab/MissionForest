Rails.application.routes.draw do
  root 'missions#index'

  devise_for :users
  resources :missions
  resources :tasks

  get 'tasks/:id/new' => 'tasks#new_child', as: :tasks_child_new
  post 'tasks/:id/create' => 'tasks#create_child', as: :tasks_child_create

  get 'missions/:mission_id/tasks/new' => 'tasks#new', as: :mission_task_new
  post 'missions/:mission_id/tasks/create' => 'tasks#create', as: :mission_task_create
end
