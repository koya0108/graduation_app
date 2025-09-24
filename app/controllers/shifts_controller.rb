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
    if data.blank? || data["staff_ids"].blank? || data["break_rooms"].blank?
      redirect_to step1_project_shifts_path(@project), alert: "データがありません"
      return
    end

    @staffs = Staff.where(id: data["staff_ids"])
    @break_rooms = BreakRoom.where(id: data ["break_room_ids"])
    @date = data["date"]
    @groups = Group.where(project_id: @project.id) # 小グループ用
  end

  def step2_create
    data = session[:shift_data]
    return redirect_to step1_project_shifts_path(@project), alert: "データがありません" if data.blank?

    staffs = Staff.where(id: data["staff_ids"])
    break_rooms = BreakRoom.where(id: data["break_rooms"])
    date = data["date"]

    # step2入力値
    staff_groups = params[:group_ids] || {}
    staff_comments = params[:comments] || {}

    # サービスクラス呼び出し
    shift = ShiftBuilder.new(
      project: @project,
      date: date,
      staffs: staffs,
      break_rooms: break_rooms,
      staff_groups: staff_groups,
      staff_comments: staff_comments,
      user: current_user
    ).build

    redirect_to project_shift_path(@project, shift), notice: "シフトを自動作成しました"
  end

  def show
    @shift = @project.shifts.find(params[:id])
    @shift_details = @shift.shift_details.includes(:staff, :break_room)
    @break_rooms = @project.break_rooms
  end

  def confirm
    @shift = @project.shifts.find(params[:id])
    @shift_details = @shift.shift_details.includes(:staff, :break_rooom)
  end

  def finalize
    @shift = @project.shifts.find(params[:id])
    @shift.update!(status: :finalized)
    redirect_to confirm_project_shift_path(@project, @shift), notice: "シフトを確定しました"
  end

  def reopen
    @shift = @project.shifts.find(params[:id])
    @shift.update!(status: :draft)
    redirect_to project_shift_path(@project, @shift)
  end

  def destroy
    @shift = @project.shifts.find(params[:id])
    @shift.destroy
    redirect_to project_shift_top_path(@project), notice: "シフトを削除しました"
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
