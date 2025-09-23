class ShiftDetailsController < ApplicationController
  before_action :set_shift_detail

  def update
    attrs = shift_detail_params.to_h

    if attrs["rest_start_time"].present?
      attrs["rest_start_time"] = build_time(attrs["rest_start_time"].to_i)
    end

    if attrs["rest_end_time"].present?
      attrs["rest_end_time"] = build_time(attrs["rest_end_time"].to_i)
    end

    if @shift_detail.update(attrs)
      render json: { success: true, detail: to_detail_json(@shift_detail) }
    else
      # DBの正しい状態に戻す
      @shift_detail.reload
      render json: {
        success: false,
        errors: @shift_detail.errors.full_messages,
        detail: to_detail_json(@shift_detail)
      }, status: :unprocessable_entity
    end
  end

  private

  def set_shift_detail
    @shift_detail = ShiftDetail.find(params[:id])
  end

  def shift_detail_params
    params.require(:shift_detail).permit(:rest_start_time, :rest_end_time, :break_room_id)
  end

  # "26" → 翌日の 2:00 に変換
  def build_time(hour_value)
    base_date = @shift_detail.shift.shift_date
    hour = hour_value % 24       # 25 → 1
    day_offset = hour_value / 24 # 25 → 1
    Time.zone.local(base_date.year, base_date.month, base_date.day, hour) + day_offset.days
  end

  def to_detail_json(detail)
    {
      id: detail.id,
      rest_start_time: (18..33).find do |h|
        detail.rest_start_time.hour == (h % 24) &&
        (h >= 24) == (detail.rest_start_time.to_date > detail.shift.shift_date)
      end,
      rest_end_time: (18..33).find do |h|
        detail.rest_end_time.hour == (h % 24) &&
        (h >= 24) == (detail.rest_end_time.to_date > detail.shift.shift_date)
      end,
      break_room_id: detail.break_room_id
    }
  end
end