class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.string :name
      t.text :description
      t.references :email, null: false, foreign_key: true

      t.timestamps
    end
  end
end
