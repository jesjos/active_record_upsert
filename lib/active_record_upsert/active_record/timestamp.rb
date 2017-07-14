module ActiveRecordUpsert
  module ActiveRecord
    module TimestampExtensions
      def _upsert_record(*args)
        if self.record_timestamps
          current_time = current_time_from_proper_timezone

          all_timestamp_attributes_in_model.each do |column|
            column = column.to_s
            if has_attribute?(column) && !attribute_present?(column)
              write_attribute(column, current_time)
            end
          end
        end

        super
      end
    end
  end
end
