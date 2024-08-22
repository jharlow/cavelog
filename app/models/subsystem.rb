class Subsystem < ApplicationRecord
  belongs_to :cave
  has_many :locations, as: :locatable, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5 }

  def path
    Rails.application.routes.url_helpers.cave_subsystem_path(cave, self)
  end
end
