class AddLongitudeAndLatitudeToCaves < ActiveRecord::Migration[7.2]
  def change
    add_column :caves, :longitude, :float
    add_column :caves, :latitude, :float
  end
end
