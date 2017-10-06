module ActiveRecordUpsert
  module ActiveRecord
    module RelationExtensions
      def upsert(existing_attributes, upsert_attributes, wheres) # :nodoc:
        substitutes, binds = substitute_values(existing_attributes)
        upsert_keys = self.klass.upsert_keys || [primary_key]

        upsert_attributes = upsert_attributes - [*upsert_keys, 'created_at']
        upsert_keys_filter = ->(o) { upsert_attributes.include?(o.name) }

        on_conflict_binds = binds.select(&upsert_keys_filter)
        vals_for_upsert = substitutes.select { |s| upsert_keys_filter.call(s.first) }

        on_conflict_do_update = arel_table.create_on_conflict_do_update
        on_conflict_do_update.target = arel_table[upsert_keys.join(',')]
        on_conflict_do_update.wheres = wheres
        on_conflict_do_update.set(vals_for_upsert)

        insert_manager = arel_table.create_insert
        insert_manager.into arel_table
        insert_manager.on_conflict = on_conflict_do_update.to_node
        insert_manager.insert substitutes

        @klass.connection.upsert(
          insert_manager,
          'SQL',
          nil, # primary key (not used)
          nil, # primary key value (not used)
          nil,
          binds + on_conflict_binds)
      end
    end
  end
end
