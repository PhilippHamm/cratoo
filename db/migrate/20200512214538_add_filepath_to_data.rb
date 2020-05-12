class AddFilepathToData < ActiveRecord::Migration[5.2]
  def change
    add_column :data, :filepath, :string
  end
end
