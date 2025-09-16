class ShiftDetail < ApplicationRecord
  belongs_to :staff
  belongs_to :shift
  belongs_to :group, optional: true
  # group_id と break_room_id は後で Group / BreakRoom モデルを作るときに関連付け予定

  validates :rest_start_time, :rest_end_time, presence: true
  validates :comment, length: { maximum:15 }

  validate :rest_time_order

  private

  def rest_time_order
    if rest_start_time.present? && rest_end_time.present? && rest_start_time >= rest_end_time
      errors.add(:rest_end_time, "は開始時間より後にしてください")
    end
  end
end
