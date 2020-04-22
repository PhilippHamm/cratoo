class CreateSongs < ActiveRecord::Migration[5.2]
  def change
    create_table :songs do |t|
      t.string :title
      t.time :duration
      t.date :publishing_year
      t.decimal :score
      t.references :artist, foreign_key: true
      t.references :publishing_country, foreign_key: true
      t.references :genre, foreign_key: true
      t.string :audio_source

      t.timestamps
    end
  end
end
