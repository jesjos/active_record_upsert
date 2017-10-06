module ActiveRecordUpsert
  module ActiveRecord
    module RelationExtensions
      def upsert(existing_attributes, upsert_attributes, wheres) # :nodoc:
        im = arel_table.create_insert
        im.into arel_table

        substitutes, binds = substitute_values(existing_attributes)
        column_arr = self.klass.upsert_keys || [primary_key]
        column_name = column_arr.join(',')

        cm = arel_table.create_on_conflict_do_update
        cm.target = arel_table[column_name]
        cm.wheres = wheres
        filter = ->(o) { [*column_arr, 'created_at'].include?(o.name) }
        filter2 = ->(o) { upsert_attributes.include?(o.name) }

        vals_for_upsert = substitutes.reject { |s| filter.call(s.first) }
        vals_for_upsert = vals_for_upsert.select { |s| filter2.call(s.first) }

        cm.set(vals_for_upsert)
        on_conflict_binds = binds.reject(&filter).select(&filter2)

        im.on_conflict = cm.to_node

        im.insert substitutes


        @klass.connection.upsert(
          im,
          'SQL',
          nil, # primary key (not used)
          nil, # primary key value (not used)
          nil,
          binds + on_conflict_binds)
      end
    end
  end
end
