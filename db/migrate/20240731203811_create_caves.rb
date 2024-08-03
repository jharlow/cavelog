class CreateCaves < ActiveRecord::Migration[7.2]
  def change
    create_table :caves do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
