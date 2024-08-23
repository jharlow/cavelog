class LogCaveCopy < ApplicationRecord
  belongs_to :log
  belongs_to :cave, optional: true

  validates :cave_title, presence: true

  before_destroy :strip_location_id_from_log_location_copies
  def strip_location_id_from_log_location_copies
    if cave.present?
      cave_locations = cave.locations
      subsystem_locations = cave.subsystems.flat_map { |ss| ss.locations }
      all_locations = cave_locations + subsystem_locations
      relevant_llcs = LogLocationCopy.where(log_id: log.id, location_id: all_locations.pluck(:id))
      relevant_llcs.destroy_all
    end
  end
end
