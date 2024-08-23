class RemoveCaveFromLogs < ActiveRecord::Migration[7.2]
  def change
    remove_reference(:logs, :cave, null: false, foreign_key: true)
  end
end
