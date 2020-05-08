class AddColumnToPlaylists < ActiveRecord::Migration[5.2]
  def change
    add_column :playlists, :song_id, :integer
  end
end
