class Log < ApplicationRecord
  belongs_to :user
  has_many :log_location_copies, dependent: :destroy
  has_many :log_cave_copies, dependent: :destroy
  has_many :log_partner_connections, dependent: :destroy
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
    total_locations = cave_locations_data[:locations].length + subsystem_locations_data.sum { |ss|
      ss[:locations].length
    }
    locations_visited_count = cave_locations_data[:locations_visited_count] + subsystem_locations_data.sum { |ss|
      ss[:locations_visited_count]
    }
    {
      cave: cave_locations_data,
      subsystems: subsystem_locations_data,
      locations_visited_count: locations_visited_count,
      total_locations: total_locations
    }
  end

  def locations_data_for_locatable(locatable)
    locations = locatable.locations.map do |location|
      connection = location.log_location_copies.where(log_id: id).first
      { data: location, connection: connection }
    end

    {
      data: locatable,
      locations: locations,
      locations_visited_count: locations.count { |location| location[:connection].present? }
    }
  end

  def format_date(datetime)
    day_suffix = case datetime.day
    when 1, 21, 31
      "st"
    when 2, 22
      "nd"
    when 3, 23
      "rd"
    else
      "th"
    end

    datetime.strftime("%b #{datetime.day}#{day_suffix} %Y")
  end

  def format_datetime(datetime)
    day_suffix = case datetime.day
    when 1, 21, 31
      "st"
    when 2, 22
      "nd"
    when 3, 23
      "rd"
    else
      "th"
    end

    datetime.strftime("%I:%M%P on ") + format_date(datetime)
  end

  def length_of_log
    seconds_diff = (end_datetime - start_datetime).to_i

    days = seconds_diff / (24 * 3600)
    seconds_diff %= (24 * 3600)
    hours = seconds_diff / 3600
    seconds_diff %= 3600
    minutes = seconds_diff / 60

    parts = []
    parts << "#{days} day#{"s" if days != 1}" if days > 0
    parts << "#{hours} hour#{"s" if hours != 1}" if hours > 0
    parts << "#{minutes} minute#{"s" if minutes != 1}" if minutes > 0

    parts.join(", ")
  end
end
