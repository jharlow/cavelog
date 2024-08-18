class PartnershipRequest < ApplicationRecord
  belongs_to :requested_by, class_name: "User"
  belongs_to :requested_to, class_name: "User"

  validate :cannot_request_self, on: :create
  validate :cannot_request_multiple_times, on: :create

  def accept!
    transaction do
      update!(accepted: true)
      Partnership.create!(user1: requested_by, user2: requested_to)
    end
  end

  private

  def cannot_request_self
    errors.add(:requested_to, "can't be the same as you") if requested_by == requested_to
  end

  def cannot_request_multiple_times
    if PartnershipRequest.exists?(requested_by: requested_by, requested_to: requested_to, accepted: false) ||
        PartnershipRequest.exists?(requested_by: requested_to, requested_to: requested_by, accepted: false)
      errors.add(:requested_to, "can't be someone you have already requested a partnership with")
    end
  end
end
