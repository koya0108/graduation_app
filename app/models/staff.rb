class Staff < ApplicationRecord
  belongs_to :project

  validates :name, presence: true
  validates :role, presence: true
end
