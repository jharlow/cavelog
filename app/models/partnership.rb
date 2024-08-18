class Partnership < ApplicationRecord
  belongs_to :user1, foreign_key: :user1_id, class_name: "User"
  belongs_to :user2, foreign_key: :user2_id, class_name: "User"
  has_many :log_partner_connections, foreign_key: :partnership_id
  has_many :logs, through: :log_partner_connections, source: :log

  validate :users_are_different
  validate :no_other_partnerships_exist, on: :create

  def includes_user?(user)
    user1 == user || user2 == user
  end

  def other_user_than(user)
    if includes_user?(user)
      return (user1 != user) ? user1 : user2
    end

    nil
  end

  before_destroy :strip_partnership_id_from_log_partner_connections
  def strip_partnership_id_from_log_partner_connections
    log_partner_connections.update_all(partnership_id: nil)
  end

  private

  def users_are_different
    errors.add(:user2, "can't be the same as user1") if user1 == user2
  end

  def no_other_partnerships_exist
    Partnership.find_by(user1: user1, user2: user2) || Partnership.find_by(user1: user2, user2: user1)
  end
end
