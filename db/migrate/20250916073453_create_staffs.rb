class CreateStaffs < ActiveRecord::Migration[8.0]
  def change
    create_table :staffs do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.string :role
      t.string :comment

      t.timestamps
    end
  end
end
