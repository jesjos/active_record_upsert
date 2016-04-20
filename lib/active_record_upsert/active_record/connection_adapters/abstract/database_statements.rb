module ActiveRecordUpsert
  module ActiveRecord
    module ConnectionAdapters
      module Abstract
        module DatabaseStatementsExtensions
          def exec_upsert(_sql, _name, _binds, _pk)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
