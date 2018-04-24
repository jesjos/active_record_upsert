module ActiveRecordUpsert
  module ActiveRecord
    module PersistenceExtensions
      def _upsert_record(upsert_attribute_names = changed, arel_condition = nil)
        existing_attributes = arel_attributes_with_values_for_create(self.attributes.keys)
        values = self.class.unscoped.upsert(existing_attributes, upsert_attribute_names, [arel_condition].compact)
        @new_record = false
        values
      end
    end

    module RelationExtensions
      def upsert(existing_attributes, upsert_attributes, wheres) # :nodoc:
        substitutes, binds = substitute_values(existing_attributes)
        upsert_keys = self.klass.upsert_keys || [primary_key]

        upsert_attributes = upsert_attributes - [*upsert_keys, 'created_at']
        upsert_keys_filter = ->(o) { upsert_attributes.include?(o.name) }

        on_conflict_binds = binds.select(&upsert_keys_filter)
        vals_for_upsert = substitutes.select { |s| upsert_keys_filter.call(s.first) }

        on_conflict_do_update = ::Arel::OnConflictDoUpdateManager.new
        on_conflict_do_update.target = arel_table[upsert_keys.join(',')]
        on_conflict_do_update.target_condition = self.klass.upsert_options[:where]
        on_conflict_do_update.wheres = wheres
        on_conflict_do_update.set(vals_for_upsert)

        insert_manager = arel_table.create_insert
        insert_manager.into arel_table
        insert_manager.on_conflict = on_conflict_do_update.to_node
        insert_manager.insert substitutes

        @klass.connection.upsert(insert_manager, "#{self} Upsert", binds + on_conflict_binds)
      end

      ::ActiveRecord::Relation.include(self)
    end

    module ConnectionAdapters
      module Postgresql
        module DatabaseStatementsExtensions
          def upsert(arel, name = nil, binds = [])
            sql = to_sql(arel, binds)
            exec_upsert(sql, name, binds)
          end
        end
      end
    end
  end
end
