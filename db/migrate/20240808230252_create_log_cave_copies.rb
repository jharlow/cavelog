class CreateLogCaveCopies < ActiveRecord::Migration[7.2]
  def change
    create_table(:log_cave_copies) do |t|
      t.references(:log, null: false, foreign_key: true)
      t.references(:cave, null: true, foreign_key: true)
      t.string(:cave_title)

      t.timestamps
    end
  end
end
