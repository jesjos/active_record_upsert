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
        assign_attributes(values.first.to_h.slice(*self.attributes.keys))
        self
      end

      def upsert(*args)
        upsert!(*args)
      rescue ::ActiveRecord::RecordInvalid
        false
      end


      def _upsert_record(upsert_attribute_names = changed, arel_condition = nil)
        existing_attributes = arel_attributes_with_values_for_create(self.attributes.keys)
        values = self.class.unscoped.upsert(existing_attributes, upsert_attribute_names, [arel_condition].compact)
        @new_record = false
        values
      end

      module ClassMethods
        def upsert!(attributes, arel_condition: nil, &block)
          if attributes.is_a?(Array)
            attributes.collect { |hash| upsert(hash, &block) }
          else
            new(attributes, &block).upsert!(
              attributes: attributes.keys, arel_condition: arel_condition, validate: true
            )
          end
        end

        def upsert(*args)
          upsert!(*args)
        rescue ::ActiveRecord::RecordInvalid
          false
        end

        def upsert_keys(*keys)
          return @_upsert_keys if keys.empty?
          keys = keys.first if keys.size == 1 # support single string/symbol, multiple string/symbols, and array
          @_upsert_keys = Array(keys).map(&:to_s)
        end
      end
    end
  end
end
