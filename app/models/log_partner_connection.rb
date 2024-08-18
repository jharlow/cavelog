class LogPartnerConnection < ApplicationRecord
  belongs_to :log
  belongs_to :partnership, optional: true

  validates :partner_name, presence: true
end
