class PopulateUniqueUsernameValues < ActiveRecord::Migration[7.2]
  def up
    User.find_each do |user|
      user.update_column(:username, "caver_#{user.id}")
    end
  end

  def down
    User.update_all(new_column: "default_value")
  end
end
