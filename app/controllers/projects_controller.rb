class ProjectsController < ApplicationController
  before_action :set_project, only: [ :edit, :update, :destroy ]

  def index
    @projects = current_user.projects
  end

  def new
    @project = current_user.projects.new
  end

  def edit
  end

  def create
    @project = current_user.projects.new(project_params)
    if @project.save
      redirect_to projects_path, notice: "プロジェクトを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to projects_path, notice: "プロジェクトを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project = current_user.projects.find(params[:id])
    @project.destroy
    redirect_to projects_path, notice: "プロジェクトを削除しました"
  end

  private

  # URLのidから該当プロジェクトを取得する共通処理
  def set_project
    @project = current_user.projects.find(params[:id])
  end

  # ストロングパラメータnameだけを受け取る
  def project_params
    params.require(:project).permit(:name)
  end
end
