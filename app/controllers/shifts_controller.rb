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

  def step2
    data = session[:shift_data]
    return redirect_to step1_project_shifts_path(@project), alert: "データがありません" if data.nil?

    @staffs = Staff.where(id: data["staff_ids"])
    @break_rooms = BreakRoom.where(id: data ["break_room_ids"])
    @date = data["date"]
    @groups = Group.where(project_id: @project.id) # 小グループ用
  end

  def step2_create
    data = session[:shift_date]
    # STEP2の入力をマージしてここで実装予定
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end