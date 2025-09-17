class Projects::ShiftsController < ApplicationController
  def top
    @project = Project.find(params[:project_id])
  end
end