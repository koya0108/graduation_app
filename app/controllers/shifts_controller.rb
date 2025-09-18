class ShiftsController < ApplicationController
  before_action :set_project

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

  def step1
    @staffs = Staff.all
    @break_rooms = BreakRoom.all
  end

  def step1_create
    session[:shift_data] = {
      date: params[:date],
      staff_ids: params[:staff_ids],
      break_rooms: params[:break_room_ids]
    }
    redirect_to step2_project_shifts_path(@project)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end