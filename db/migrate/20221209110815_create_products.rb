class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.string :status
      t.integer :quantity
      t.text :description

      t.timestamps
    end
  end
end
