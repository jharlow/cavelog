class LogCaveCopy < ApplicationRecord
  belongs_to :log
  belongs_to :cave, optional: true

  validates :cave_title, presence: true
end
