module ActiveRecordUpsert
  module ActiveRecord
    module PersistenceExtensions

      def upsert
        raise ::ActiveRecord::ReadOnlyRecord, "#{self.class} is marked as readonly" if readonly?
        raise ::ActiveRecord::RecordSavedError, "Can't upsert a record that has already been saved" if persisted?
        values = run_callbacks(:save) {
          run_callbacks(:create) {
            _upsert_record
          }
        }
        assign_attributes(values.first.to_h)
        self
      rescue ::ActiveRecord::RecordInvalid
        false
      end

      def _upsert_record(attribute_names = changed)
        attributes_values = arel_attributes_with_values_for_create(attribute_names)
        values = self.class.unscoped.upsert attributes_values
        @new_record = false
        values
      end

      module ClassMethods
        def upsert(attributes, &block)
          if attributes.is_a?(Array)
            attributes.collect { |hash| upsert(hash, &block) }
          else
            new(attributes, &block).upsert
          end
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
