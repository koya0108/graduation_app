class Shift < ApplicationRecord
  belongs_to :user
  belongs_to :project
  has_many :shift_details, dependent: :destroy

  enum :shift_category, { day: 0, night: 1 }
  enum :status, { draft: 0, finalized: 1 }

  validates :shift_date, presence: true
  validates :shift_category, presence: true
  validates :shift_date, uniqueness: { scope: [ :project_id, :shift_category ], message: "このシフトはすでに存在します" }
end
