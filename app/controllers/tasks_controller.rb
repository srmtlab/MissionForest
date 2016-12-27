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
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)
    @task.user = current_user
    @task.mission_id = params[:mission_id]
    @task.parend_id = 0

    if @task.save
      redirect_to tasks_show_path(@task.id), notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  # POST /1/tasks
  def create_child
    @task = Task.new(task_params)
    @task.user = current_user
    @task.mission = current_user.missions.last
    @task.parend_id = params[:id]

    if @task.save
      redirect_to tasks_show_path(@task.id), notice: 'Task was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      redirect_to tasks_index_path, notice: 'Task was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
    redirect_to tasks_url, notice: 'Task was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def task_params
      params[:task].permit(:title, :description, :mission_id, :parend_id)
    end
end
