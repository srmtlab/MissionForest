# coding: utf-8
class MissionsController < ApplicationController
  # before_action :set_mission, only: [:show, :edit, :update, :destroy]
  rescue_from Banken::NotAuthorizedError, with: :user_not_authorized

  # GET /missions
  def index
    @missions = []
    Mission.all.order(created_at: :desc).each do |mission|
      root_task = mission.reload.root_task
      notify = root_task.notify
      if notify == 'publish' or notify == 'lod' or mission.admins.include?(current_user) or mission.participants.include?(current_user)
        @missions.push(mission)
      end
    end
  end

  # GET /missions/new
  def new
    authorize!
    @mission = Mission.new
    @mission.tasks.build
  end

  # POST /missions
  def create
    authorize!
    @mission = Mission.new(mission_params)
    @mission.user = current_user
    @mission.participants.push(current_user)
    @mission.admins.push(current_user)
    if @mission.save
      task = Task.new
      task.title = @mission.title
      task.description = @mission.description
      task.user = current_user
      task.mission = @mission
      task.direct_mission = @mission
      @mission.tasks.push(task)
      @mission.root_task = task
      @mission.save
      if task.save
        redirect_to mission_path(@mission), notice: 'ミッションが作成されました'
      else
        render :new
      end
    else
      render :new
    end
  end

  # GET /missions/1
  def show
    @lod = (ENV["LOD"].to_s == "true")
    @mission = Mission.find(params[:id]).reload
    # @mission.hierarchy = get_hierarchy(@mission)
    authorize! @mission
  end

  def mission_params
    params[:mission].permit(:title, :description)
  end

  private
  def user_not_authorized
    redirect_to root_path, alert: 'ミッションを閲覧する権限がありません'
  end

  # # =====================================================
  # # GET /api/missions/1/tasks
  # def show_tasks
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  #   all_tasks = get_all_tasks(@mission)
  #   hierarchy = get_hierarchy(@mission)
  #   taskjson = {all_tasks: all_tasks, hierarchy: hierarchy}
  #   render :json => taskjson
  # end
  #
  # # PUT /api/missions/1/update_hierarchy
  # def update_hierarchy
  #   def tree2pcrelation(tree)
  #     def recursion(tree, pcrelation)
  #       parent = tree['id']
  #
  #       if ! tree['children'].nil?
  #         tree['children'].each do |child|
  #           pair = []
  #           pair.push(parent)
  #           pair.push(child[1]['id'])
  #           pcrelation.push(pair)
  #           recursion(child[1], pcrelation)
  #         end
  #       end
  #     end
  #
  #     pcrelation = []
  #     recursion(tree, pcrelation)
  #
  #     pcrelation
  #   end
  #   authorize!
  #
  #   pcrelation = tree2pcrelation(params[:tree].to_unsafe_h)
  #
  #   pcrelation.each do |pair|
  #     task = Task.find(pair[1])
  #     task.sub_task_of = pair[0].to_i
  #     task.save!
  #   end
  # end
  #
  #
  # # DELETE /api/missions/1/participant/2
  # def participation_user
  #   @mission = Mission.find(params[:mission_id])
  #   authorize! @mission
  #
  #   @participation = Participation.new
  #   @participation.user = User.find(params[:user_id])
  #   @participation.mission = @mission
  #
  #   if @participation.save
  #     render :json => {participation: @participation}
  #   end
  # end
  #
  #
  #
  # # GET /missions/1/edit
  # def edit
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  # end
  #
  #
  #
  # # POST /api/missions/create
  # def api_create
  #   if params[:isdebug] == 'True'
  #     render :json => {'mission_id' => 10}
  #   else
  #     authorize!
  #     @mission = Mission.new(mission_params)
  #     @mission.user = current_user
  #     @mission.participants.push(current_user)
  #     @mission.admins.push(current_user)
  #     if @mission.save
  #       task = Task.new(root_task_params)
  #       task.user = current_user
  #       task.mission = @mission
  #       task.direct_mission = @mission
  #       if params[:issecret] != 'True'
  #         task.notify = :lod
  #       end
  #       @mission.tasks.push(task)
  #       if task.save
  #         render :json => {'mission_id' => @mission.id}
  #       end
  #     end
  #   end
  # end
  #
  # # PATCH/PUT /missions/1
  # def update
  #   authorize! @mission
  #
  #   if @mission.update(mission_params)
  #     redirect_to mission_path(@mission), notice: 'ミッションが更新されました'
  #   else
  #     render :edit
  #   end
  # end
  #
  # # DELETE /missions/1
  # def destroy
  #   authorize! @mission
  #
  #   @mission.destroy
  #   redirect_to missions_path, notice: 'ミッションが削除されました'
  # end
  #
  # # GET /missions/1/add_admin
  # def add_admin
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  # end
  #
  # # PATCH PUT /missions/1/add_admin_update
  # def add_admin_update
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  #
  #   user_name = params[:admin]
  #
  #   user = User.find_by(name: user_name)
  #   if not @mission.admins.include?(user)
  #     @mission.admins.push(user)
  #   end
  #   if not @mission.participants.include?(user)
  #     @mission.participants.push(user)
  #   end
  #
  #
  #   if @mission.save
  #     redirect_to mission_path(@mission), notice: user_name + 'さんが参加しました'
  #   else
  #     render :mission_add_admin
  #   end
  # end
  #
  # # DELETE /api/missions/1/delete_admin/1
  # def api_delete_admin
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  #
  #   @mission.admins.delete(params[:user_id])
  #
  #   if @mission.save
  #     render :json => {'mission_id' => @mission.id, 'admin_id' => params[:user_id]}
  #   end
  # end
  #
  # # GET /missions/1/add_participant
  # def add_participant
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  # end
  #
  # # PUT /missions/1/add_participant_update
  # def add_participant_update
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  #
  #   user_name = params[:participant]
  #
  #   user = User.find_by(name: user_name)
  #
  #   if not @mission.participants.include?(user)
  #     @mission.participants.push(user)
  #   end
  #
  #   if @mission.save
  #     redirect_to mission_path(@mission), notice: user_name + 'さんが参加しました'
  #   else
  #     render :mission_add_participant
  #   end
  # end
  #
  # # GET /missions/1/add_participant_me
  # def add_participant_me
  #   @mission = Mission.find(params[:id])
  #   user = current_user
  #   @mission.participants.push(user)
  #
  #   if @mission.save
  #     redirect_to mission_path(@mission), notice: user.name + 'さんが参加しました'
  #   else
  #     render :mission_add_participant
  #   end
  # end
  #
  # # DELETE /api/missions/1/delete_participant/1
  # def api_delete_participant
  #   @mission = Mission.find(params[:id])
  #   authorize! @mission
  #
  #   @mission.participants.delete(params[:user_id])
  #
  #   if @mission.save
  #     render :json => {'mission_id' => @mission.id, 'participant_id' => params[:user_id]}
  #   end
  # end
  #
  #
  # private
  # def get_all_tasks(mission)
  #   tasks = []
  #   mission.tasks.each do |task|
  #     task_detail = {}
  #     task_detail['id'] = task.id
  #     task_detail['mission_id'] = task.mission_id
  #     task_detail['notify'] = task.notify
  #     task_detail['status'] = task.status
  #     task_detail['sub_task_of'] = task.sub_task_of
  #     task_detail['title'] = task.title
  #     task_detail['user_id'] = task.user_id
  #     task_detail['description'] = task.description
  #     task_detail['deadline_at'] = task.deadline_at
  #     task_detail['participants'] = task.participants
  #     tasks.push(task_detail)
  #   end
  #   tasks
  # end
  #
  # def get_hierarchy(mission)
  #   def generate_tree(task)
  #     tree = {}
  #
  #     notify = task.notify
  #     if (notify == 'own' or notify == 'organize') and task.user.id != current_user.try(:id)
  #       return nil
  #     end
  #
  #     tree["id"] = task.id
  #     tree["name"] = task.title
  #     tree["description"] = task.description
  #     tree["deadline_at"] = task.deadline_at
  #     tree["created_at"] = task.created_at
  #     tree["status"] = task.status
  #     tree["notify"] = notify
  #
  #     if ! task.subtasks[0].nil?
  #       tree["children"] = []
  #       task.subtasks.each do |child|
  #         childtree = generate_tree(child)
  #
  #         if ! childtree.nil?
  #           tree["children"].push(childtree)
  #         end
  #       end
  #     end
  #     tree
  #   end
  #
  #   task = mission.root_task
  #   tree = generate_tree(task)
  # end
  #
  #
  #
  #
  # def root_task_params
  #   params[:mission].permit(:title, :description)
  # end
  #
  # def set_mission
  #   @mission = Mission.find(params[:id])
  # end
end
