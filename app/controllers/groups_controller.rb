class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :update, :edit, :delete]
  
  def index
    @groups = Group.all
  end

  def show
  end

  def new
    @groups = Group.new
  end

  def update
  end

  def delete
  end

  private

  def group_params
    params.require(:group).permit(:title)
  end

  def set_group
    @groups = Group.find(params[:id])
  end
end
