Rails.application.routes.draw do
  root 'missions#index'
  devise_for :users

  get 'missions' => 'missions#index', as: :missions_index
  get 'missions/new' => 'missions#new', as: :missions_new
  get 'missions/:id/edit' => 'missions#edit', as: :missions_edit
  post 'missions/create' => 'missions#create', as: :missions_create
  put 'missions/:id' => 'missions#update', as: :missions_update
  delete 'missions/:id' => 'missions#destroy', as: :missions_destroy
  get 'missions/:id' => 'missions#show', as: :missions_show

  get 'tasks' => 'tasks#index', as: :tasks_index
  # get 'tasks/new' => 'tasks#new', as: :tasks_new
  get 'tasks/:id/edit' => 'tasks#edit', as: :tasks_edit
  # post 'tasks/create' => 'tasks#create', as: :tasks_create
  put 'tasks/:id' => 'tasks#update', as: :tasks_update
  delete 'tasks/:id' => 'tasks#destroy', as: :tasks_destroy
  get 'tasks/:id' => 'tasks#show', as: :tasks_show

  get 'tasks/:id/new' => 'tasks#new_child', as: :tasks_child_new
  post 'tasks/:id/create' => 'tasks#create_child', as: :tasks_child_create

  get 'missions/:mission_id/tasks/new' => 'tasks#new', as: :tasks_new
  post 'missions/:mission_id/tasks/create' => 'tasks#create', as: :tasks_create
end
