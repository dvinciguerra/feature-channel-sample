class CreateAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :assets do |t|
      t.string :name
      t.text :description
      t.string :bucket_url

      t.timestamps
    end
  end
end
