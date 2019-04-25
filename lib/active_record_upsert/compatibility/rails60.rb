module ActiveRecordUpsert
  module ActiveRecord
    module TransactionsExtensions
      def upsert(*args)
        with_transaction_returning_status { super }
      end
    end
  end
end
