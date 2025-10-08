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
    # 古いセッションを自動リセット
    if session[:shift_data].present?
      prev_date = session[:shift_data]["date"]
      # URLパラメータの日付が異なる、または新規アクセスならリセット
      if params[:date].present? && prev_date != params[:date]
        session.delete(:shift_data)
      end
    end

    @staffs = @project.staffs
    @break_rooms = @project.break_rooms

    data = session[:shift_data]
    if data.present?
      @selected_staff_ids = data["staff_ids"] || []
      @selected_break_room_ids = data["break_room_ids"] || []
      @date = data["date"]
    else
      @selected_staff_ids = []
      @selected_break_room_ids = []
      @date = params[:date]
    end
  end

  def step1_create
    session[:shift_data] = {
      date: params[:date],
      staff_ids: params[:staff_ids],
      break_room_ids: params[:break_room_ids]
    }
    redirect_to step2_project_shifts_path(@project)
  end

  def edit_step1
    @shift = @project.shifts.find(params[:id])

    session[:shift_data] = {
      date: @shift.shift_date.strftime("%Y-%m-%d"),
      staff_ids: @shift.shift_details.pluck(:staff_id),
      break_room_ids: @shift.shift_details.pluck(:break_room_id)
    }

    redirect_to step1_project_shifts_path(@project, shift_id: @shift.id)
  end

  def step2
    data = session[:shift_data]
    if data.blank? || data["staff_ids"].blank? || data["break_room_ids"].blank?
      redirect_to step1_project_shifts_path(@project), alert: "データがありません"
      return
    end

    @staffs = @project.staffs.where(id: data["staff_ids"])
    @break_rooms = @project.break_rooms.where(id: data["break_room_ids"])
    @date = data["date"]
    @groups = Group.where(project_id: @project.id) # 小グループ用
    @shift = @project.shifts.find_by(id: params[:shift_id])
  end

  def update_step2
    data = session[:shift_data]
    return redirect_to step1_project_shifts_path(@project), alert: "データがありません" if data.blank?

    @shift = @project.shifts.find(params[:id])
    staffs = Staff.where(id: data["staff_ids"])
    break_rooms = BreakRoom.where(id: data["break_room_ids"])
    date = data["date"]
    staff_groups = params[:group_ids] || {}

    @shift.transaction do
      @shift.shift_details.destroy_all

      ShiftBuilder.new(
        project: @project,
        date: date,
        staffs: staffs,
        break_rooms: break_rooms,
        staff_groups: staff_groups,
        user: current_user
      ).rebuild(@shift)
    end

    session.delete(:shift_data)
    redirect_to project_shift_path(@project, @shift), notice: "シフトを更新しました"
  end

  def step2_create
    data = session[:shift_data]
    return redirect_to step1_project_shifts_path(@project), alert: "データがありません" if data.blank?

    staffs = Staff.where(id: data["staff_ids"])
    break_rooms = BreakRoom.where(id: data["break_room_ids"])
    date = data["date"]
    staff_groups = params[:group_ids] || {}

    existing_shift = @project.shifts.find_by(shift_date: date)

    if existing_shift # 既存シフト→上書き更新
      ShiftBuilder.new(
        project: @project,
        date: date,
        staffs: staffs,
        break_rooms: break_rooms,
        staff_groups: staff_groups,
        user: current_user
      ).rebuild(existing_shift)
      target_shift = existing_shift
      notice_message = "シフトを更新しました"
    else
      # 新規シフト→新しく作成
      target_shift = ShiftBuilder.new(
        project: @project,
        date: date,
        staffs: staffs,
        break_rooms: break_rooms,
        staff_groups: staff_groups,
        user: current_user
      ).build
      notice_message = "シフトを作成しました"
    end

    session.delete(:shift_data)
    redirect_to project_shift_path(@project, target_shift), notice: notice_message
  end

  def show
    @shift = @project.shifts.find(params[:id])
    @shift_details = @shift.shift_details.includes(:staff, :break_room)
    @break_rooms = @project.break_rooms
  end

  def confirm
    @shift = @project.shifts.find(params[:id])
    @shift_details = @shift.shift_details.includes(:staff, :break_room)

    respond_to do |format|
      format.html # confirm.html.erbをそのまま表示
      format.pdf do
        render pdf: "shift_#{@shift.id}",
               template: "shifts/pdf",
               formats: [ :html ],
               layout: "pdf",
               page_size: "A4",
               orientation: "Landscape",
               disposition: "inline"
      end
    end
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
    @project = current_user.projects.find(params[:project_id])
  end
end
