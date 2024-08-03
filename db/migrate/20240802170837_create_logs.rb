class CreateLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :logs do |t|
      t.references :cave, null: false, foreign_key: true
      t.text :personal_comments
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
