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

  validates :username, presence: true, uniqueness: { case_sensitive: false }

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
    User
      .joins(
        "INNER JOIN partnerships ON (partnerships.user1_id = users.id AND partnerships.user2_id = #{id}) OR (partnerships.user2_id = users.id AND partnerships.user1_id = #{id})"
      )
      .distinct
  end

  def is_partner_of?(user)
    if self == user
      nil
    else
      partners.exists?(user.id)
    end
  end
end
