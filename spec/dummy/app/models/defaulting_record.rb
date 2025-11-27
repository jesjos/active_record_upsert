class DefaultingRecord < ApplicationRecord
  upsert_keys exclude: [:uuid]
end
