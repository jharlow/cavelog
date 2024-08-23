class LogLocationCopy < ApplicationRecord
  belongs_to :log, optional: true
  belongs_to :location, optional: true

  validates :location_title, presence: true
end
