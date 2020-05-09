class DeleteColumnStyleFromSongs < ActiveRecord::Migration[5.2]
  def change
    remove_column :songs, :style_id
  end
end
