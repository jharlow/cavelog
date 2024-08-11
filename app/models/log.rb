class Log < ApplicationRecord
  belongs_to :user
  has_many :log_location_copies, dependent: :destroy
  has_many :log_cave_copies, dependent: :destroy
  accepts_nested_attributes_for :log_cave_copies
  has_many :caves, through: :log_cave_copies
  has_many :locations, through: :log_location_copies

  validates :personal_comments, presence: true, length: { minimum: 10 }
  validates :start_datetime, presence: true, not_in_future: true
  validates :end_datetime, presence: true, not_in_future: true, not_before_other_attribute: { with: :start_datetime }

  def unconnected_caves
    log_cave_copies.where(cave_id: nil)
  end

  def unconnected_locations
    log_location_copies.where(location_id: nil)
  end

  def locations_data
    { caves: caves.map { |cave| cave_locations_data(cave) } }
  end

  def cave_locations_data(cave)
    cave_locations_data = locations_data_for_locatable(cave)
    subsystem_locations_data = cave.subsystems.map { |subsystem| locations_data_for_locatable(subsystem) }
    locations_visited_count = cave_locations_data[:locations].reject { |loc| loc[:is_in_log] }.length +
      subsystem_locations_data.sum { |ss| ss[:locations].reject { |loc| loc[:is_in_log] }.length }
    { cave: cave_locations_data, subsystems: subsystem_locations_data, locations_visited_count: locations_visited_count }
  end

  def locations_data_for_locatable(locatable)
    {
      data: locatable,
      locations: locatable.locations.map do |location|
        connected_copy = location.log_location_copies.where(log_id: id)
        { data: location, is_in_log: connected_copy.present? }
      end
    }
  end
end
