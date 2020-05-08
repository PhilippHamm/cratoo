class CreatePlaylistSongs < ActiveRecord::Migration[5.2]
  def change
    create_table :playlist_songs do |t|
      t.integer :song_id, :integer, foreign_key: true
      t.integer :playlist_id, :integer, foreign_key: true

      t.timestamps
    end
  end
end
