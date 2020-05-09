class CreateTableSongStyles < ActiveRecord::Migration[5.2]
  def change
    create_table :table_song_styles do |t|
      t.references :song, foreign_key: true
      t.references :style, foreign_key: true
    end
  end
end
