class CreateData < ActiveRecord::Migration[5.2]
  def change
    create_table :data do |t|
      t.string :genre
      t.integer :quantity

      t.timestamps
    end
  end
end
