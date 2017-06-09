module ActiveRecordUpsert
  module ActiveRecord
    module TimestampExtensions
      def _upsert_record(*args)
        if self.record_timestamps
          current_time = current_time_from_proper_timezone
          if ActiveRecord::VERSION::MAJOR >= 5 && ActiveRecord::VERSION::MINOR >= 1
            all_timestamp_attributes_in_model.each do |column|
              column = column.to_s
              if has_attribute?(column) && !attribute_present?(column)
                write_attribute(column, current_time)
              end
            end
          else
            all_timestamp_attributes.each do |column|
              column = column.to_s
              if has_attribute?(column) && !attribute_present?(column)
                write_attribute(column, current_time)
              end
            end
          end
        end

        super
      end
    end
  end
end
