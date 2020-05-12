class AddImportedToDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :data, :imported, :boolean, default: false
  end
end
