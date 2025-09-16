class CreateShiftDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :shift_details do |t|
      t.references :staff, null: false, foreign_key: true
      t.references :shift, null: false, foreign_key: true
      t.integer :group_id
      t.integer :break_room_id
      t.datetime :rest_start_time
      t.datetime :rest_end_time
      t.string :comment

      t.timestamps
    end
  end
end
