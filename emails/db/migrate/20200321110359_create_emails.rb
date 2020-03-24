class CreateEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :emails do |t|
      t.string :name
      t.string :subject
      t.text :body
      t.integer :asset_id, null: true

      t.timestamps
    end
  end
end
