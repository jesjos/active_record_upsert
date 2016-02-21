module ActiveRecordUpsert
  module ActiveRecord
    module TransactionsExtensions
      def upsert(*args)
        rollback_active_record_state! do
          with_transaction_returning_status { super }
        end
      end
    end

    ::ActiveRecord::Base.prepend(TransactionsExtensions)
  end
end
