module ActiveRecordUpsert
  module ActiveRecord
    module ConnectionAdapters
      module Abstract
        module DatabaseStatementsExtensions
          def exec_upsert(_sql, _name, _binds, _pk)
            raise NotImplementedError
          end

          def upsert(arel, name = nil, pk = nil, id_value = nil, sequence_name = nil, binds = [])
            sql, binds, pk, _sequence_name = sql_for_upsert(to_sql(arel, binds), pk, id_value, sequence_name, binds)
            exec_upsert(sql, name, binds, pk)
          end

          def sql_for_upsert(sql, pk, id_value, sequence_name, binds)
            [sql, binds, pk, sequence_name]
          end
        end
      end
    end
  end
end
