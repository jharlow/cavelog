class CreateLogPartnerConnections < ActiveRecord::Migration[7.2]
  def change
    create_table(:log_partner_connections) do |t|
      t.references(:log, null: false, foreign_key: true)
      t.references(:partnership, null: true, foreign_key: true)
      t.string(:partner_name)

      t.timestamps
    end
  end
end
