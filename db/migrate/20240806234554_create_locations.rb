class CreateLocations < ActiveRecord::Migration[7.2]
  def change
    create_table :locations do |t|
      t.string :title
      t.text :description
      t.references :locatable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
