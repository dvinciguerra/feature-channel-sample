class CreateEmails < ActiveRecord::Migration[6.0]
  def change
    create_table :emails do |t|
      t.string :name
      t.string :subject
      t.text :body
      t.references :asset, null: false, foreign_key: true

      t.timestamps
    end
  end
end
