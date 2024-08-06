class Cave < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :logs
  has_many :subsystems

  validates :title, presence: true
  validates :description, presence: true, length: { minimum: 10 }
end
