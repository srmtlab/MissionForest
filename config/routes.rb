Rails.application.routes.draw do
  get 'users/index'

  get 'users/show'

  root 'missions#index'

  devise_for :users, :controllers => {
               :registrations => 'users/registrations',
               :sessions => 'sessions'
  }
  resources :users, :only => [:index, :show]
  resources :missions
  resources :tasks
  resource :authentication_token, only: [:update, :destroy]


  get 'tasks/:id/new' => 'tasks#new_child', as: :tasks_child_new
  post 'tasks/:id/create' => 'tasks#create_child', as: :tasks_child_create

  get 'missions/:mission_id/tasks/new' => 'tasks#new', as: :mission_task_new
  post 'missions/:mission_id/tasks/create' => 'tasks#create', as: :mission_task_create

  # api
  get 'api/missions/:id/tasks' => 'missions#show_tasks'
  get 'api/missions/:mission_id/participation/:user_id' => 'missions#participation_user'
  post 'api/missions/:id/task' => 'tasks#new_task'
  put 'api/tasks/:id/update' => 'tasks#update_child'
  delete 'api/tasks/:id/delete' => 'tasks#delete_child'
  post 'api/missions/create' => 'missions#api_create'
end
