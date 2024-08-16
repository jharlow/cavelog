class UpdateUserNameFields < ActiveRecord::Migration[7.2]
  def change
    remove_column(:users, :name, :string)
    add_column(:users, :first_name, :string)
    add_column(:users, :last_name, :string)
  end
end
