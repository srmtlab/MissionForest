Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'missions/:id/add_participant_me' => 'missions#add_participant_me', as: :mission_add_me
  delete 'api/tasks/:id/delete_participant/:user_id' => 'tasks#api_delete_participant'

  put 'api/tasks/:id/add_participant' => 'tasks#add_participant'
  
  delete 'api/missions/:id/delete_admin/:user_id' => 'missions#api_delete_admin'
  
  put 'missions/:id/add_admin_update' => 'missions#add_admin_update', as: :mission_add_admin_update
  
  get 'missions/:id/add_admin' => 'missions#add_admin', as: :mission_add_admin

  
  delete 'api/missions/:id/delete_participant/:user_id' => 'missions#api_delete_participant'
  
  put 'missions/:id/add_participant_update' => 'missions#add_participant_update', as: :mission_add_participant_update
  
  get 'missions/:id/add_participant' => 'missions#add_participant', as: :mission_add_participant

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
