class ShiftsController < ApplicationController
  def top
    @project = Project.find(params[:project_id])
    @shifts = @project.shifts.select(:id, :shift_date)
  end

  def fetch
    project = Project.find(params[:project_id])
    start_date = params[:start].to_date
    end_date   = params[:end].to_date

    shifts = project.shifts.where(shift_date: start_date..end_date)
    render json: shifts.select(:id, :shift_date)
  end
end