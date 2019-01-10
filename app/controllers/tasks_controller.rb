# coding: utf-8
class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks
  def index
    @tasks = Task.all.order(created_at: :desc).all
  end

  # GET /tasks/1
  def show
    task = Task.find(params[:id])
    mission = task.mission
    mission_id = mission.id.to_s
    task_id = task.id.to_s
    url = "/missions/" + mission_id + "?taskid=" + task_id
    redirect_to(url, :status => :found)
  end

  # GET /tasks/new
  def new
    @task = Task.new
    @task.mission_id = params[:mission_id]
  end

  # GET /tasks/1/new
  def new_child
    @task = Task.new
    @task.mission = Task.find(params[:id]).mission
    @task.parent_id = params[:id]
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /api/missions/1/task
  def new_task
    authorize! @task
    task = Task.new(task_params)
    task.user = current_user
    task.mission_id = params[:id]
    add_participant_to_ancestor_tasks(task, current_user)
    
    if task.save
      mission = Mission.find(task.mission_id)
      all_tasks = get_all_tasks(mission)
      hierarchy = get_hierarchy(mission)
      taskjson = {all_tasks: all_tasks, hierarchy: hierarchy}
      render :json => { task: task, task_data: taskjson }
    end
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)
    @task.user = current_user
    @task.mission = Mission.find(params[:mission_id])

    if @task.save
      redirect_to mission_path(@task.mission), notice: 'タスクが作成されました'
    else
      render :new
    end
  end

  # POST /1/tasks
  def create_child
    @task = Task.new(task_params)
    @task.user = current_user
    @task.mission_id = Task.find(task_params[:parent_id]).mission.id
    @task.participants.push(current_user)

    if @task.save
      redirect_to mission_path(@task.mission), notice: 'タスクが作成されました'
    else
      render :new
    end
  end

  # PUT api/tasks/1/update
  def update_child
    task = Task.find(params[:id])
    mission_id = task.mission_id
   
    task.update(task_params)
    mission = Mission.find(mission_id)
    all_tasks = get_all_tasks(mission)
    hierarchy = get_hierarchy(mission)
    taskjson = {all_tasks: all_tasks, hierarchy: hierarchy}
    render :json => { task: task, task_data: taskjson }
  end

  # DELETE api/tasks/1/delete
  def delete_child
    task = Task.find(params[:id])
    mission_id = task.mission_id
   
    if task.destroy
      mission = Mission.find(mission_id)
      all_tasks = get_all_tasks(mission)
      hierarchy = get_hierarchy(mission)
      taskjson = {all_tasks: all_tasks, hierarchy: hierarchy}
      render :json => { task: task , task_data: taskjson}
    end
  end
  
  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      redirect_to mission_path(@task.mission), notice: 'タスクが更新されました'
    else
      render :edit
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
    redirect_to mission_path(@task.mission), notice: 'タスクが削除されました'
  end

  # PUT api/tasks/1/add-participant
  def add_participant
    task = Task.find(params[:id])
    user = User.find(params[:user_id])

    add_participant_to_ancestor_tasks(task, user)

    if task.save
      mission_id = task.mission_id
      mission = Mission.find(mission_id)
      all_tasks = get_all_tasks(mission)
      hierarchy = get_hierarchy(mission)
      taskjson = {all_tasks: all_tasks, hierarchy: hierarchy}
      render :json => { task: task , task_data: taskjson}
    end
  end


  # DELETE /api/tasks/1/delete_participant/1
  def api_delete_participant
    @task = Task.find(params[:id])
    authorize! @task.participants

    @task.participants.delete(params[:user_id])

    if @task.save
      mission_id = @task.mission_id
      mission = Mission.find(mission_id)
      all_tasks = get_all_tasks(mission)
      hierarchy = get_hierarchy(mission)
      taskjson = {all_tasks: all_tasks, hierarchy: hierarchy}
      render :json => {task_id: @task.id, participant_id: params[:user_id], task_data: taskjson}
    end
  end
  
  private
  def add_participant_to_ancestor_tasks(task, user)
    anc_list = get_ancestors(task)
    anc_list.each do |anc|
      if not anc.participants.include?(user)
        anc.participants.push(user)
        anc.save
      end
    end
  end
  
  def get_ancestors(task)
    def ancestor(nexttask)
      if nexttask.sub_task_of.present? then
        ancestors_list = ancestor(Task.find(nexttask.sub_task_of))
      else
        ancestors_list = []
      end
      ancestors_list.push(nexttask)
      return ancestors_list
    end
    return ancestor(task)
  end
  
  def get_all_tasks(mission)
    tasks = []
    mission.tasks.each do |task|
      task_detail = {}
      task_detail['id'] = task.id
      task_detail['mission_id'] = task.mission_id
      task_detail['notify'] = task.notify
      task_detail['status'] = task.status
      task_detail['sub_task_of'] = task.sub_task_of
      task_detail['title'] = task.title
      task_detail['user_id'] = task.user_id
      task_detail['description'] = task.description
      task_detail['deadline_at'] = task.deadline_at
      task_detail['participants'] = task.participants
      tasks.push(task_detail)
    end
    return tasks
  end
  
  def get_hierarchy(mission)
    def generate_tree(task)
      tree = {}
      
      notify = task.notify
      if (notify == 'own' or notify == 'organize') and task.user.id != current_user.try(:id)
        return nil
      end
      
      
      tree["id"] = task.id
      tree["name"] = task.title
      tree["description"] = task.description
      tree["deadline_at"] = task.deadline_at
      tree["status"] = task.status
      tree["notify"] = notify

      
      if ! task.subtasks[0].nil? then
        tree["children"] = []
        task.subtasks.each do |child|
          childtree = generate_tree(child)
          
          if ! childtree.nil? then
            tree["children"].push(childtree)
          end
        end
      end
      return tree
    end

    task = mission.root_task
    tree = generate_tree(task)
    return tree
  end
  
  def set_task
    @task = Task.find(params[:id])
  end
  
  def task_params
    params[:task].permit(:title, :description, :mission_id, :sub_task_of, :deadline_at, :status, :notify)
  end
end
