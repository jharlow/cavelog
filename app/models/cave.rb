class Cave < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  include Geocoder::Model::ActiveRecord

  has_many :subsystems, dependent: :destroy
  has_many :locations, as: :locatable, dependent: :destroy
  has_many :log_cave_copies
  has_many :logs, through: :log_cave_copies

  validates :title, presence: true
  validates :description, presence: true, length: {minimum: 10}
  validates :longitude, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180}, allow_blank: true
  validates :latitude, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}, allow_blank: true

  # Custom validation method for parsing
  validate :parse_coordinates

  reverse_geocoded_by(:latitude, :longitude) do |cave, results|
    if (geo = results.first)
      cave.address = geo.address
    end
  end
  # auto-fetch coordinates
  after_validation :geocode
  # auto-fetch address
  after_validation :reverse_geocode

  def address
    results = Geocoder.search([latitude, longitude])
    results.first.address if results.any?
  end

  def path
    Rails.application.routes.url_helpers.cave_path(self)
  end

  before_destroy :strip_cave_id_from_log_cave_copies
  def strip_cave_id_from_log_cave_copies
    log_cave_copies.update_all(cave_id: nil)
  end

  private

  def parse_coordinates
    begin
      if latitude && !longitude
        errors.add(:longitude, "must be present if latitude is")
      elsif longitude
        self.longitude = parse_float(longitude)
      end
    rescue ArgumentError
      errors.add(:longitude, "must be a valid floating point number")
    end

    begin
      if longitude && !latitude
        errors.add(:latitude, "must be present if longitude is")
      elsif latitude
        self.latitude = parse_float(latitude)
      end
    rescue ArgumentError
      errors.add(:latitude, "must be a valid floating point number")
    end
  end

  def parse_float(value)
    Float(value)
  rescue ArgumentError, TypeError
    raise ArgumentError, "Invalid float format"
  end
end
