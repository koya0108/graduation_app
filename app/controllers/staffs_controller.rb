class StaffsController < ApplicationController
  before_action :set_project
  before_action :set_staff, only: [ :edit, :update, :destroy ]

  def index
    @staffs = @project.staffs
  end

  def new
    @staff = @project.staffs.new
  end

  def create
    @staff = @project.staffs.new(staff_params)
    if @staff.save
      redirect_to project_staffs_path(@project), notice: "スタッフを登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @staff.update(staff_params)
      redirect_to project_staffs_path(@project), notice: "スタッフを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @staff.destroy
    redirect_to project_staffs_path(@project), notice: "スタッフを削除しました"
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_staff
    @staff = @project.staffs.find(params[:id])
  end

  def staff_params
    params.require(:staff).permit(:name, :position, :comment)
  end
end

