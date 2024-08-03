class Log < ApplicationRecord
  belongs_to :cave
  belongs_to :user

  validates :personal_comments, presence: true, length: { minimum: 10 }
end
