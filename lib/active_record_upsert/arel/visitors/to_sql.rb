module ActiveRecordUpsert
  module Arel
    module Visitors
      module ToSqlExtensions
        def visit_Arel_Nodes_InsertStatement(o, collector)
          collector = super
          if o.on_conflict
            maybe_visit o.on_conflict, collector
          else
            collector
          end
        end

        def visit_Arel_Nodes_OnConflict o, collector
          collector << "ON CONFLICT "
          collector << " (#{quote_column_name o.target.name}) ".gsub(',', '","')
          maybe_visit o.action, collector
        end

        def visit_Arel_Nodes_DoNothing _o, collector
          collector << "DO NOTHING"
        end

        def visit_Arel_Nodes_DoUpdateSet o, collector
          wheres = o.wheres

          collector << "DO UPDATE "
          unless o.values.empty?
            collector << " SET "
            collector = inject_join o.values, collector, ", "
          end

          unless wheres.empty?
            collector << " WHERE "
            collector = inject_join wheres, collector, " AND "
          end

          collector
        end

        def visit_Arel_Nodes_ExcludedColumn o, collector
          collector << "EXCLUDED.#{quote_column_name o.column}"
          collector
        end

        def table_exists?(name)
          schema_cache.data_source_exists?(name)
        end
      end

      ::Arel::Visitors::ToSql.prepend(ToSqlExtensions)
    end
  end
end
