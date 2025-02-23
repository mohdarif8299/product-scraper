class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title
      t.string :url
      t.decimal :price
      t.string :image
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
