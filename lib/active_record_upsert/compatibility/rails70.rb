module ActiveRecordUpsert
  module ActiveRecord
    module PersistenceExtensions
      module ClassMethods
        def __substitute_values(values, table)
          values.map do |name, value|
            attr = table[name]
            unless ::Arel.arel_node?(value) || value.is_a?(::ActiveModel::Attribute)
              type = type_for_attribute(attr.name)
              value = predicate_builder.build_bind_attribute(attr.name, type.cast(value))
            end
            [attr, value]
          end
        end

        def _upsert_record(existing_attributes, upsert_attributes_names, wheres, opts) # :nodoc:
          upsert_keys = opts[:upsert_keys] || self.upsert_keys || [primary_key]
          upsert_options = opts[:upsert_options] || self.upsert_options
          upsert_attributes_names = upsert_attributes_names - [*upsert_keys, 'created_at']

          existing_attributes = existing_attributes
            .transform_keys { |name| _prepare_column(name) }
            .reject { |key, _| key.nil? }

          upsert_attributes_names = upsert_attributes_names
            .map { |name| _prepare_column(name) }
            .compact

          values_for_upsert = existing_attributes.select { |(name, _value)| upsert_attributes_names.include?(name) }

          insert_manager = arel_table.compile_upsert(
            upsert_keys,
            upsert_options,
            __substitute_values(values_for_upsert, arel_table),
            __substitute_values(existing_attributes, arel_table),
            wheres
          )

          connection.upsert(insert_manager, "#{self} Upsert")
        end
      end
    end

    module TransactionsExtensions
      def upsert(*args)
        with_transaction_returning_status { super }
      end
    end

    module ConnectAdapterExtension
      def upsert(*args)
        ::ActiveRecord::Base.clear_query_caches_for_current_thread
        super
      end

      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(self)
    end
  end
end
