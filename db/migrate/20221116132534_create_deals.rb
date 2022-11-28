class CreateDeals < ActiveRecord::Migration[5.2]
  def change
    create_table :deals do |t|
      t.integer :customer_id
      t.string :title
      t.integer :price
      t.integer :amount
      t.float :tax

      t.timestamps
    end
  end
end
