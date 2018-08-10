class Account < ApplicationRecord
  upsert_keys :name, where: 'active is TRUE'

  has_many :vehicles
end
