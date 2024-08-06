class AddEndDatetimeToLog < ActiveRecord::Migration[7.2]
  def change
    add_column :logs, :end_datetime, :datetime
  end
end
