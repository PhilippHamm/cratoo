class DeleteColumnSongIdFromPlaylists < ActiveRecord::Migration[5.2]
  def change
    remove_columns :playlists, :song_id
  end
end
