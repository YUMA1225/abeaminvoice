class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers do |t|
      t.integer :user_id
      t.string :name
      t.string :code
      t.string :manager

      t.timestamps
    end
  end
end
