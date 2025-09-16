class CreateBreakRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :break_rooms do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
