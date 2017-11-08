# coding: utf-8
class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :edit, :update, :destroy]
  
  # GET /missions
  def index
    @missions = Mission.order(created_at: :desc).all
    #@missions = Mission.all
  end

  # GET /missions/1
  def show
    @mission = Mission.find(params[:id])
#    @mission.hierarchy = get_hierarchy(@mission)
    authorize! @mission
  end

  # GET /api/missions/1/tasks
  def show_tasks
    #def get_name(hash)
    #  task_id = hash["id"]
    #  @task = Task.find(task_id)
    #  hash["name"] = @task.title
    #  hash["description"] = @task.description
    #  hash["deadline_at"] = @task.deadline_at
    #  hash["status"] = @task.status
    #  if ! hash["children"].nil? then
    #    hash["children"].each do |child|
    #      get_name(child)
    #    end
    #  end
    #end
    #
    #@mission = Mission.find(params[:id])
    #authorize! @mission
    #
    #hierarchy = @mission.hierarchy
    #if hierarchy.nil? then
    #  @task = Task.find_by(mission_id: params[:id])
    #  hierarchy = {}
    #  hierarchy["id"] = @task.id
    #  hierarchy["children"] = []
    #  input_hierarchy = hierarchy.to_json
    #  @mission.hierarchy = input_hierarchy
    #  @mission.save
    #  hierarchy["name"] = @task.title
    #  hierarchy["description"] = @task.description
    #  hierarchy["deadline_at"] = @task.deadline_at
    #  hierarchy["status"] = @task.status
    #  render :json => hierarchy
    #else
    #  hierarchy = JSON.parse(hierarchy)
    #  get_name(hierarchy)
    #  render :json => hierarchy
    #end
    @mission = Mission.find(params[:id])
    authorize! @mission
    hierarchy = get_hierarchy(@mission)
    render :json => hierarchy
  end


  # GET /api/missions/1/participation/2
  def participation_user
    @mission = Mission.find(params[:mission_id])
    authorize! @mission

    @participation = Participation.new
    @participation.user = User.find(params[:user_id])
    @participation.mission = @mission

    if @participation.save
      render :json => {participation: @participation}
    end
  end
  
  # GET /missions/new
  def new
    authorize!
    @mission = Mission.new
    @mission.tasks.build
  end

  # GET /missions/1/edit
  def edit
    @mission = Mission.find(params[:id])
    authorize! @mission
  end

  # POST /missions
  def create
    authorize!
    @mission = Mission.new(mission_params)
    @mission.user = current_user
    if @mission.save
      @task = Task.new(root_task_params)
      @task.user = current_user
      @task.mission = @mission
      @task.direct_mission = @mission
      @mission.tasks[0] = @task
      #@mission.tasks.create(root_task_params)
      #@mission.tasks[0].user = current_user
      #@mission.tasks[0].direct_mission = @mission
      #if @mission.tasks[0].save
      if @task.save
        redirect_to mission_path(@mission), notice: 'ミッションが作成されました'
      else
        render :new
      end
    else
      render :new
    end
  end

  # POST /api/missions/create
  def api_create
    @mission = Mission.new(mission_params)
    @mission.user = User.find(25)
    if @mission.save
      @task = Task.new(root_task_params)
      @task.user = User.find(25)
      @task.mission = @mission
      @task.direct_mission = @mission
      @mission.tasks[0] = @task
      if @task.save
        render :json => {'mission_id' => @mission.id}
      else
        render :new
      end
    else
      render :new
    end
  end

  # PATCH/PUT /missions/1
  def update
    authorize! @mission
    
    if @mission.update(mission_params)
      hierarchy = @mission.hierarchy
      hierarchy = JSON.parse(hierarchy)
      task_id = hierarchy["id"]
      @task = Task.find(task_id)
      if @task.update(root_task_params)
        redirect_to mission_path(@mission), notice: 'ミッションが更新されました'
      else
        render :edit
      end
    else
      render :edit
    end
  end

  # DELETE /missions/1
  def destroy
    authorize! @mission
    
    @mission.destroy
    redirect_to missions_path, notice: 'ミッションが削除されました'
  end

  private
  def get_hierarchy(mission)
    def generate_tree(task)
      tree = {}
      tree["id"] = task.id
      tree["name"] = task.title
      tree["description"] = task.description
      tree["deadline_at"] = task.deadline_at
      tree["status"] = task.status
      
      if ! task.subtasks[0].nil? then
        tree["children"] = []
        task.subtasks.each do |child|
          tree["children"].push(generate_tree(child))
        end
      end
      return tree
    end

    task = mission.root_task
    tree = generate_tree(task)

    return tree
  end
  
  def set_mission
    @mission = Mission.find(params[:id])
  end
  
  def mission_params
    params[:mission].permit(:title, :description, :hierarchy)
  end
  
  def root_task_params
    params[:mission].permit(:title, :description)
  end
end
