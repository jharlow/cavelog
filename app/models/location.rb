class Location < ApplicationRecord
  belongs_to :locatable, polymorphic: true
  has_many :log_location_copies

  validates :title, presence: true, length: { minimum: 5 }

  def path
    if locatable.is_a?(Subsystem)
      Rails.application.routes.url_helpers.cave_subsystem_location_path(locatable.cave, locatable, self)
    else
      Rails.application.routes.url_helpers.cave_location_path(locatable, self)
    end
  end

  def get_cave
    locatable.is_a?(Subsystem) ? locatable.cave : locatable
  end

  before_destroy :strip_location_id_from_log_location_copies
  def strip_location_id_from_log_location_copies
    log_location_copies.update_all(location_id: nil)
  end
end
