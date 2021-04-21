module ActiveRecordUpsert
  module ActiveRecord
    module PersistenceExtensions
      def upsert!(attributes: nil, arel_condition: nil, validate: true, opts: {})
        raise ::ActiveRecord::ReadOnlyRecord, "#{self.class} is marked as readonly" if readonly?
        raise ::ActiveRecord::RecordSavedError, "Can't upsert a record that has already been saved" if persisted?
        validate == false || perform_validations || raise_validation_error
        run_callbacks(:save) {
          run_callbacks(:create) {
            attributes ||= changed
            attributes = attributes +
              timestamp_attributes_for_create_in_model +
              timestamp_attributes_for_update_in_model
            _upsert_record(attributes.map(&:to_s).uniq, arel_condition, opts)
          }
        }

        self
      end

      def upsert(*args)
        upsert!(*args)
      rescue ::ActiveRecord::RecordInvalid
        false
      end

      def _upsert_record(upsert_attribute_names = changed, arel_condition = nil, opts = {})
        existing_attribute_names = attributes_for_create(attributes.keys)
        existing_attributes = attributes_with_values(existing_attribute_names)
        values = self.class._upsert_record(existing_attributes, upsert_attribute_names, [arel_condition].compact, opts)
        @attributes = self.class.attributes_builder.build_from_database(values.first.to_h)
        @new_record = false
        changes_applied
        values
      end

      def upsert_operation
        created_record = self['_upsert_created_record']
        return if created_record.nil?
        created_record ? :create : :update
      end

      module ClassMethods
        def upsert!(attributes, arel_condition: nil, validate: true, opts: {}, &block)
          if attributes.is_a?(Array)
            attributes.collect { |hash| upsert(hash, &block) }
          else
            new(attributes, &block).upsert!(
              attributes: attributes.keys, arel_condition: arel_condition, validate: validate, opts: opts
            )
          end
        end

        def upsert(*args)
          upsert!(*args)
        rescue ::ActiveRecord::RecordInvalid
          false
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
            _substitute_values(values_for_upsert),
            _substitute_values(existing_attributes),
            wheres
          )

          connection.upsert(insert_manager, "#{self} Upsert")
        end

        def _prepare_column(column)
          column = attribute_alias(column) if attribute_alias?(column)

          if columns_hash.key?(column)
            column
          elsif reflections.key?(column)
            reflections[column].foreign_key
          end
        end

        def upsert_keys(*keys)
          return @_upsert_keys if keys.empty?
          options = keys.extract_options!
          keys = keys.first if keys.size == 1 # support single string/symbol, multiple string/symbols, and array
          return if keys.nil?
          @_upsert_keys = Array(keys)
          @_upsert_options = options
        end

        def upsert_options
          @_upsert_options || {}
        end

        def inherited(subclass)
          super
          subclass.upsert_keys(upsert_keys, upsert_options)
        end
      end
    end
  end
end
