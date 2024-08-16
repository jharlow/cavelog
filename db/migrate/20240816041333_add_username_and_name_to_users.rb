class AddUsernameAndNameToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column(:users, :username, :string, null: false, default: "caver")
    add_column(:users, :name, :string)
  end
end
