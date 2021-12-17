module ActiveRecordUpsert
  module Arel
    module TableExtensions
      def compile_upsert(upsert_keys, upsert_options, upsert_values, insert_values, wheres)
        # Support non-attribute key (like `md5(my_attribute)``)
        target = self[upsert_options.key?(:literal) ? ::Arel::Nodes::SqlLiteral.new(upsert_options[:literal]) : upsert_keys.join(',')]
        on_conflict_do_update = ::Arel::OnConflictDoUpdateManager.new

        on_conflict_do_update.target = target
        on_conflict_do_update.target_condition = upsert_options[:where]
        on_conflict_do_update.wheres = wheres
        on_conflict_do_update.set(upsert_values)

        insert_manager = ::Arel::InsertManager.new
        insert_manager.on_conflict = on_conflict_do_update.to_node
        insert_manager.into insert_values.first.first.relation
        insert_manager.insert(insert_values)
        insert_manager
      end
    end
    ::Arel::Table.prepend(TableExtensions)
  end
end