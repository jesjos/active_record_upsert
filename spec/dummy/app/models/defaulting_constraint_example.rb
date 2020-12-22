class DefaultingConstraintExample < ApplicationRecord
  upsert_keys exclude: [:color]
end