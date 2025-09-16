class Staff < ApplicationRecord
  belongs_to :project
  has_many :shift_details, dependent: :destroy

  validates :name, presence: true
  validates :role, presence: true
  validates :comment, length: { maximum:15 }
end
