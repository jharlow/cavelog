class Log < ApplicationRecord
  belongs_to :user
  has_many :log_location_copies, dependent: :destroy
  has_many :log_cave_copies, dependent: :destroy
  accepts_nested_attributes_for :log_cave_copies

  validates :personal_comments, presence: true, length: { minimum: 10 }
  validates :start_datetime, presence: true, not_in_future: true
  validates :end_datetime, presence: true, not_in_future: true, not_before_other_attribute: { with: :start_datetime }
end
