module ActiveRecordUpsert
  module ActiveRecord
    module TransactionsExtensions
      def upsert(*args, **kwargs)
        with_transaction_returning_status { super }
      end

      def upsert!(*args, **kwargs)
        with_transaction_returning_status { super }
      end
    end

    module ConnectAdapterExtension
      def upsert(*args, **kwargs)
        ::ActiveRecord::Base.clear_query_caches_for_current_thread
        super
      end

      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(self)
    end
  end
end
