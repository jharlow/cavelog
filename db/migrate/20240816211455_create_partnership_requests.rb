class CreatePartnershipRequests < ActiveRecord::Migration[7.2]
  def change
    create_table(:partnership_requests) do |t|
      t.references(:requested_by, null: false, foreign_key: { to_table: :users })
      t.references(:requested_to, null: false, foreign_key: { to_table: :users })
      t.boolean(:accepted, default: false)

      t.timestamps
    end
  end
end
