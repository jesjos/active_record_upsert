module ActiveRecordUpsert
  module ActiveRecord
    module PersistenceExtensions
      def upsert!(attributes: nil, arel_condition: nil, validate: true)
        raise ::ActiveRecord::ReadOnlyRecord, "#{self.class} is marked as readonly" if readonly?
        raise ::ActiveRecord::RecordSavedError, "Can't upsert a record that has already been saved" if persisted?
        validate == false || perform_validations || raise_validation_error
        values = run_callbacks(:save) {
          run_callbacks(:create) {
            attributes ||= changed
            attributes = attributes +
              timestamp_attributes_for_create_in_model +
              timestamp_attributes_for_update_in_model
            _upsert_record(attributes.map(&:to_s).uniq, arel_condition)
          }
        }

        # When a migration adds a column to a table, the upsert will start
        # returning the new attribute, and assign_attributes will fail,
        # because Rails doesn't know about it yet (until the app is restarted).
        #
        # This checks that only known attributes are being assigned.
        assign_attributes(values.first.to_h.slice(*self.attributes.keys))
        self
      end

      def upsert(*args)
        upsert!(*args)
      rescue ::ActiveRecord::RecordInvalid
        false
      end

      def _upsert_record(upsert_attribute_names = changed, arel_condition = nil)
        existing_attributes = attributes_with_values_for_create(self.attributes.keys)
        values = self.class._upsert_record(existing_attributes, upsert_attribute_names, [arel_condition].compact)
        @new_record = false
        values
      end

      module ClassMethods
        def upsert!(attributes, arel_condition: nil, validate: true, &block)
          if attributes.is_a?(Array)
            attributes.collect { |hash| upsert(hash, &block) }
          else
            new(attributes, &block).upsert!(
              attributes: attributes.keys, arel_condition: arel_condition, validate: validate
            )
          end
        end

        def upsert(*args)
          upsert!(*args)
        rescue ::ActiveRecord::RecordInvalid
          false
        end

        def _upsert_record(existing_attributes, upsert_attributes_names, wheres) # :nodoc:
          upsert_keys = self.upsert_keys || [primary_key]
          upsert_attributes_names = upsert_attributes_names - [*upsert_keys, 'created_at']
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
