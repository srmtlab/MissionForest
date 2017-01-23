class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  # GET /tasks
  def index
    @tasks = Task.all.order(created_at: :desc).all
  end

  # GET /tasks/1
  def show
    @task = Task.find(params[:id])
    @children = Task.where("parend_id = ?", @task.id)
  end

  # GET /tasks/new
  def new
    @task = Task.new
    @task.mission_id = params[:mission_id]
    @task.parend_id = 0
  end

  # GET /tasks/1/new
  def new_child
    @task = Task.new
    @task.mission = Task.find(params[:id]).mission
    @task.parend_id = params[:id]
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)
    @task.user = current_user
    @task.mission = Mission.find(params[:mission_id])
    @task.parend_id = 0

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
    @task.mission_id = Task.find(task_params[:parend_id]).mission.id

    if @task.save
      redirect_to mission_path(@task.mission), notice: 'タスクが作成されました'
    else
      render :new
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

  private
    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params[:task].permit(:title, :description, :mission_id, :parend_id, :deadline_at)
    end
end
