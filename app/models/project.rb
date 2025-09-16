class Project < ApplicationRecord
  has_many :staffs, dependent: :destroy
end
