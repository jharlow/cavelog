class CreateSubsystems < ActiveRecord::Migration[7.2]
  def change
    create_table :subsystems do |t|
      t.string :title
      t.text :description
      t.references :cave, null: false, foreign_key: true

      t.timestamps
    end
  end
end
