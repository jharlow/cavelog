class Cave < ApplicationRecord
  has_many :logs

  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 10 }
end
