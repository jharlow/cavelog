class Location < ApplicationRecord
  belongs_to :locatable, polymorphic: true

  validates :title, presence: true, length: {minimum: 5}

  def path
    if locatable.is_a?(Subsystem)
      Rails.application.routes.url_helpers.cave_subsystem_location_path(locatable.cave, locatable, self)
    else
      Rails.application.routes.url_helpers.cave_location_path(locatable, self)
    end
  end
end
