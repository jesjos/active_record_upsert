module ActiveRecordUpsert
  module ActiveRecord
    module ConnectionAdapters
      module Postgresql
        module DatabaseStatementsExtensions
          def upsert(arel, name = nil, binds = [])
            sql, binds = to_sql_and_binds(arel, binds)
            exec_upsert(sql, name, binds)
          end

          def exec_upsert(sql, name, binds)
            exec_query("#{sql} RETURNING *, (xmax = 0) AS _upsert_created_record", name, binds)
          end
        end
      end
    end
  end
end
