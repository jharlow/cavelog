class Cave < ApplicationRecord
  include Geocoder::Model::ActiveRecord
  reverse_geocoded_by(:latitude, :longitude) do |cave, results|
    if (geo = results.first)
      cave.address = geo.address
    end
  end

  has_many :subsystems, dependent: :destroy
  has_many :locations, as: :locatable, dependent: :destroy
  has_many :log_cave_copies
  has_many :logs, through: :log_cave_copies

  validates :title, presence: true
  validates(
    :longitude,
    numericality: {
      greater_than_or_equal_to: -180,
      less_than_or_equal_to: 180,
      message: "must be a valid floating point number, positive for East, negative for West."
    },
    allow_blank: true
  )
  validates(
    :latitude,
    numericality: {
      greater_than_or_equal_to: -90,
      less_than_or_equal_to: 90,
      message: "must be a valid floating point number, positive for North, negative for South"
    },
    allow_blank: true
  )
  validate :parse_coordinates
  after_validation :set_address, if: -> { latitude_changed? || longitude_changed? }, unless: :skip_geocoding

  attr_accessor :skip_geocoding
  # auto-fetch coordinates
  after_validation :geocode, unless: :skip_geocoding
  # auto-fetch address
  after_validation :reverse_geocode, unless: :skip_geocoding

  def path
    Rails.application.routes.url_helpers.cave_path(self)
  end

  before_destroy :strip_cave_id_from_log_cave_copies
  def strip_cave_id_from_log_cave_copies
    log_cave_copies.update_all(cave_id: nil)
  end

  def self.search(search)
    if search
      where([ "title ILIKE ?", "%#{search}%" ])
    else
      all
    end
  end

  def self.search_by_text_or_location(query)
    geocodable = begin
      results = Geocoder.search(query)
      results.present? && results.first.coordinates.present?
    rescue
      false
    end

    geocoded_caves = geocodable ? Cave.near(query) : Cave.none
    title_caves = Cave.search(query).records
    (title_caves + geocoded_caves).uniq
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
      errors.add(:longitude, "must be a valid floating point number, positive for East, negative for West")
    end

    begin
      if longitude && !latitude
        errors.add(:latitude, "must be present if longitude is")
      elsif latitude
        self.latitude = parse_float(latitude)
      end

    rescue ArgumentError
      errors.add(:latitude, "must be a valid floating point number, positive for North, negative for South")
    end
  end

  def parse_float(value)
    Float(value)
  rescue ArgumentError, TypeError
    raise ArgumentError, "Invalid float format"
  end

  def set_address
    reverse_geocode if !skip_geocoding && latitude.present? && longitude.present?
  end
end
