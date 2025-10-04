class ShiftBuilder
  # 休憩時間(2h)を定数として定義
  SLOT_LENGTH = 2.hours

  # サービスクラスの初期化処理
  # コントローラーから渡されたデータをインスタンス編集に保存
  def initialize(project:, date:, staffs:, break_rooms:, staff_groups:, user:)
    @project = project
    @date = date.to_date
    @staffs = staffs
    @break_rooms = break_rooms
    @staff_groups = staff_groups # STEP2フォームで入力したデータ
    @user = user
    @shift_category = "night" # MVPでは夜勤固定
    @groups = staffs.group_by { |s| staff_groups[s.id.to_s] || "ungrouped" } # グループ毎にスタッフをまとめたハッシュ
  end

  def build
    shift = @project.shifts.create!(
      shift_date: @date,
      user: @user,
      shift_category: @shift_category
    )

    slots = generate_slots
    midnight_slots = slots.select { |s| midnight?(s) }
    other_slots = slots.reject { |s| midnight?(s) }

    # その他のスロットを深夜に近い順でソート
    other_slots.sort_by! do |slot|
      distance_to_midnight(slot[:start])
    end

    @assigned_staff_ids = [] # 割り当て済のスタッフを記録

    assign_staffs(shift, midnight_slots) # 深夜帯から先に割り当て
    assign_staffs(shift, other_slots) # 残りは前後の時間
    shift
  end

  private

  def distance_to_midnight(time)
    # 0時を基準に近さを数値化
    midnight = time.change(hour: 0)
    [ (time - midnight).abs, (time - (midnight + 1.day)).abs ].min
  end

  def generate_slots
    start_time = Time.zone.local(@date.year, @date.month, @date.day, 18, 0, 0) # ← JST基準で18:00固定
    end_time = Time.zone.local((@date + 1).year, (@date + 1).month, (@date + 1).day, 9, 0, 0)

    slots = []
    while start_time < end_time
      slots << { start: start_time, end: start_time + SLOT_LENGTH }
      start_time += SLOT_LENGTH
    end
    slots
  end

  # スロット開始時間が深夜かどうかを判定
  def midnight?(slot)
    (0..5).include?(slot[:start].hour)
  end

  def assign_staffs(shift, slots)
    room_index = 0

    slots.each do |slot|
      used_groups = []

      @break_rooms.size.times do
        room = @break_rooms[room_index % @break_rooms.size]
        room_index += 1

        # 未割り当てのスタッフを探す
        staff = @staffs.find do |s|
          group_id = @staff_groups[s.id.to_s].presence || "ungrouped"
          !@assigned_staff_ids.include?(s.id) &&
          !used_groups.include?(group_id)
        end
        next unless staff # 全員割り当て済なら終了

        raw_gid = @staff_groups[staff.id.to_s]
        group_id = raw_gid.present? ? raw_gid.to_i : nil

        shift.shift_details.create!(
            staff: staff,
            group_id: group_id,
            break_room: room,
            rest_start_time: slot[:start],
            rest_end_time: slot[:end],
            comment: staff.comment
            )

        @assigned_staff_ids << staff.id # ここで割り当て済に追加
        used_groups << @staff_groups[staff.id.to_s] # 同じスロットでは同じグループ禁止
      end
    end
  end

  # そのスロットの時間帯でまだ使っていない休憩室を探す
  # 見つかったらその休憩室を返す
  def available_break_room(slot, shift)
    @break_rooms.find do |room|
      !shift.shift_details.exists?(
        break_room: room,
        rest_start_time: slot[:start]..slot[:end]
      )
    end
  end
end
