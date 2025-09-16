class BreakRoom < ApplicationRecord
  belongs_to :project
  has_many :shift_details, dependent: :destroy

  validates :name, presence: true
end
