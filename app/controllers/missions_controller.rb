class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :edit, :update, :destroy]

  # GET /missions
  def index
    @missions = Mission.order(created_at: :desc).all
  end

  # GET /missions/1
  def show
    @mission = Mission.find(params[:id])
  end

  # GET /api/missions/1/tasks
  def show_tasks
    mission = Mission.find(params[:id])
    hierarchy = mission.hierarchy
    render :json => hierarchy
  end

  # POST /api/missions/1/hierarchy
  def update_hierarchy
    mission = Mission.find(params[:id])
    mission.hierarchy = mission_params[:hierarchy]
    if mission.save
      render :json => { mission: mission }
    end
  end

  # GET /missions/new
  def new
    @mission = Mission.new
  end

  # GET /missions/1/edit
  def edit
  end

  # POST /missions
  def create
    @mission = Mission.new(mission_params)
    @mission.user = current_user
    @mission.hierarchy = {
      'id': '0',
      'children': []
    }

    if @mission.save
      redirect_to mission_path(@mission), notice: 'ミッションが作成されました'
    else
      render :new
    end
  end

  # PATCH/PUT /missions/1
  def update
    if @mission.update(mission_params)
      redirect_to mission_path(@mission), notice: 'ミッションが更新されました'
    else
      render :edit
    end
  end

  # DELETE /missions/1
  def destroy
    @mission.destroy
    redirect_to missions_path, notice: 'ミッションが削除されました'
  end

  private
    def set_mission
      @mission = Mission.find(params[:id])
    end

    def mission_params
      params[:mission].permit(:title, :description, :hierarchy)
    end
end
