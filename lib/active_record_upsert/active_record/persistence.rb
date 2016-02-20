module ActiveRecordUpsert
  module ActiveRecord
    module PersistenceExtensions

      def upsert
        raise ReadOnlyRecord, "#{self.class} is marked as readonly" if readonly?
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
      end
    end

    ::ActiveRecord::Base.prepend(PersistenceExtensions)
    ::ActiveRecord::Base.extend(PersistenceExtensions::ClassMethods)
  end
end
