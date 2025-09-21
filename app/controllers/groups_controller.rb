class GroupsController < ApplicationController
  before_action :set_project
  before_action :set_group, only: [ :edit, :update, :destroy ]

  def index
    @groups = @project.groups
  end

  def new
    @group = @project.groups.new
  end

  def create
    @group = @project.groups.new(group_params)
    if @group.save
      redirect_to project_groups_path(@project)
    else
      @groups = @project.groups
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def destroy
    @group.destroy
    redirect_to project_groups_path(@project)
  end

  def update
    if @group.update(group_params)
      redirect_to project_groups_path(@project), notice: "スタッフを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_group
    @group = @project.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end
