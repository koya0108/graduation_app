class Project < ApplicationRecord
  has_many :staffs, dependent: :destroy
  has_many :shifts, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :break_rooms, dependent: :destroy

  validates :name, presence: true
end
