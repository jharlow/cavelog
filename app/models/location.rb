class Location < ApplicationRecord
  belongs_to :locatable, polymorphic: true

  validates :title, presence: true, length: { minimum: 5 }
end
