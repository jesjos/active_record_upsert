class ConstraintExample < ActiveRecord::Base
  upsert_keys constraint: 'my_unique_constraint'
end
