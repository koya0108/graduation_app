class RenameRoleToPositionInStaffs < ActiveRecord::Migration[8.0]
  def change
    rename_column :staffs, :role, :position
  end
end
