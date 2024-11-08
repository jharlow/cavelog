class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise(
    :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable
  )
  has_many(
    :sent_partnership_requests,
    class_name: "PartnershipRequest",
    foreign_key: :requested_by_id,
    dependent: :destroy
  )
  has_many(
    :received_partnership_requests,
    class_name: "PartnershipRequest",
    foreign_key: :requested_to_id,
    dependent: :destroy
  )

  has_many :partnerships_as_user1, class_name: "Partnership", foreign_key: :user1_id, dependent: :destroy
  has_many :partnerships_as_user2, class_name: "Partnership", foreign_key: :user2_id, dependent: :destroy

  has_many :logs, dependent: :destroy

  enum :role, {admin: 0, expert: 1, user: 2}

  validates :username, presence: true, uniqueness: {case_sensitive: false}

  def can_edit
    if logs.count > 5 || role != "user"
      return true
    end

    false
  end

  def can_delete
    if role == "user"
      return false
    end

    true
  end

  def has_pending_request_with_user?(user)
    if self == user
      nil
    else
      received_partnership_requests.exists?(requested_by: user, accepted: false)
    end
  end

  def has_sent_request_to_user?(user)
    if self == user
      nil
    else
      sent_partnership_requests.exists?(requested_to: user, accepted: false)
    end
  end

  def partners
    Partnership.where("user1_id = :id OR user2_id = :id", id: id)
  end

  def is_partner_of?(user)
    if self == user
      nil
    else
      partners.where("user1_id = :id OR user2_id = :id", id: user.id).exists?
    end
  end

  def partnership_with(user)
    partners.where("user1_id = :id OR user2_id = :id", id: user.id).first
  end

  def name_for(user)
    if user.nil? || !first_name || self == user || !is_partner_of?(user)
      username
    elsif !last_name
      first_name + " (#{username})"
    else
      first_name + " " + last_name
    end
  end
end
