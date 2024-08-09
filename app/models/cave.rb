class Cave < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :logs
  has_many :subsystems
  has_many :locations, as: :locatable
  has_many :log_cave_copies

  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 10 }

  def path
    Rails.application.routes.url_helpers.cave_path(self)
  end
end
