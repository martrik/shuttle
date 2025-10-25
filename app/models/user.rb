class User < ApplicationRecord
  has_many :deployments, dependent: :destroy

  validates :railway_api_key, presence: true, uniqueness: true
end
