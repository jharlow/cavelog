class CreateLogLocationCopies < ActiveRecord::Migration[7.2]
  def change
    create_table(:log_location_copies) do |t|
      t.references(:log, null: false, foreign_key: true)
      t.references(:location, null: true, foreign_key: true)
      t.string(:location_title)

      t.timestamps
    end
  end
end
