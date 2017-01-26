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

  def show_tasks
    mission = Mission.find(params[:id])
    datasource = {
      'id': 0,
      'name': mission.title,
      'children': []
    }
    render :json => datasource
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
      params[:mission].permit(:title, :description)
    end
end
