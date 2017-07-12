class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.integer :product_id
      t.integer :quantity
      t.decimal :line_item_total
      t.string :order_id
      t.string :integer

      t.timestamps
    end
  end
end
