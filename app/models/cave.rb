class Cave < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :subsystems, dependent: :destroy
  has_many :locations, as: :locatable, dependent: :destroy
  has_many :log_cave_copies
  has_many :logs, through: :log_cave_copies

  validates :title, presence: true
  validates :description, presence: true, length: {minimum: 10}

  def path
    Rails.application.routes.url_helpers.cave_path(self)
  end

  before_destroy :strip_cave_id_from_log_cave_copies
  def strip_cave_id_from_log_cave_copies
    log_cave_copies.update_all(cave_id: nil)
  end
end
