class CreatePublishingCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_countries do |t|
      t.string :name

      t.timestamps
    end
  end
end
