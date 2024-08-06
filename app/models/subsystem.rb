class Subsystem < ApplicationRecord
  belongs_to :cave

  validates :title, presence: true, length: { minimum: 5 }
end
