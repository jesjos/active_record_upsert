module ActiveRecordUpsert
  module ActiveRecord
    module RelationExtensions
      def upsert(values) # :nodoc:
        primary_key_value = nil

        if primary_key && Hash === values
          primary_key_value = values[values.keys.find { |k|
            k.name == primary_key
          }]
        end

        im = arel_table.create_insert
        im.into arel_table

        substitutes, binds = substitute_values values

        cm = arel_table.create_on_conflict_do_update
        cm.target = arel_table[primary_key]

        filter = ->(o) { [primary_key, 'created_at'].include?(o.name) }
        cm.set(substitutes.reject { |s| filter.call(s.first) })
        on_conflict_binds = binds.reject(&filter)

        im.on_conflict = cm.to_node

        im.insert substitutes

        @klass.connection.upsert(
          im,
          'SQL',
          primary_key,
          primary_key_value,
          nil,
          binds + on_conflict_binds)
      end
    end

    ::ActiveRecord::Relation.include(RelationExtensions)
  end
end
