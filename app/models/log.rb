class Log < ApplicationRecord
  belongs_to :cave
  belongs_to :user

  validates :personal_comments, presence: true, length: { minimum: 10 }
  validates :start_datetime, presence: true, not_in_future: true
  validates :end_datetime, presence: true, not_in_future: true, not_before_other_attribute: { with: :start_datetime }
end
