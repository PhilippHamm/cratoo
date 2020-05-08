class AddColumnToSongs < ActiveRecord::Migration[5.2]
  def change
    add_column :songs, :style_id, :string
  end
end
