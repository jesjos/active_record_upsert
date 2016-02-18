# module ActiveRecordUpsert
#   module Arel
#     module CrudExtensions
#       def create_on_conflict_do_update
#         OnConflictDoUpdateManager.new
#       end
#     end
#
#     ::Arel::Crud.prepend(CrudExtensions)
#   end
# end
module Arel
  class Table
    def create_on_conflict_do_update
      OnConflictDoUpdateManager.new
    end
  end
end
