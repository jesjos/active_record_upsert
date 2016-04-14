module ActiveRecordUpsert
  module ActiveRecord
    module ConnectionAdapters
      module Postgresql
        module DatabaseStatementsExtensions
          def sql_for_upsert(sql, pk, id_value, sequence_name, binds)
            sql = "#{sql} RETURNING *"
            super
          end

          def exec_upsert(sql, name, binds, pk)
            exec_query(sql, name, binds)
          end
        end
      end
    end
  end
end
