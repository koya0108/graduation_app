class AddPendingEmployeeCodeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :pending_employee_code, :string
  end
end
