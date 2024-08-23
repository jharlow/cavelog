class AddGroupSizeToLog < ActiveRecord::Migration[7.2]
  def change
    add_column :logs, :group_size, :integer
  end
end
