class AddStartDatetimeToLog < ActiveRecord::Migration[7.2]
  def change
    add_column :logs, :start_datetime, :datetime
  end
end
