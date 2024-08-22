class AddAddressDataToCaves < ActiveRecord::Migration[7.2]
  def change
    add_column :caves, :address, :string
  end
end
