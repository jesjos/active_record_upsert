# module ActiveRecordUpsert
#   module Arel
#     module Nodes
#       module InsertStatementExtensions
#         attr_accessor :on_conflict
#
#         def initialize
#           @on_conflict = nil
#           super()
#         end
#
#         def hash
#           [@relation, @columns, @values, @select, @on_conflict].hash
#         end
#
#         def eql? other
#           self.class == other.class &&
#             self.relation == other.relation &&
#             self.columns == other.columns &&
#             self.select == other.select &&
#             self.values == other.values &&
#             self.on_conflict == other.on_conflict
#         end
#       end
#
#       ::Arel::Nodes::InsertStatement.prepend(InsertStatementExtensions)
#     end
#   end
# end

module Arel
  module Nodes
    class InsertStatement
      attr_accessor :on_conflict

      def initialize
        super()
        @relation = nil
        @columns  = []
        @values   = nil
        @select   = nil
        @on_conflict = nil
      end

      def hash
        [@relation, @columns, @values, @select, @on_conflict].hash
      end

      def eql? other
        self.class == other.class &&
          self.relation == other.relation &&
          self.columns == other.columns &&
          self.select == other.select &&
          self.values == other.values &&
          self.on_conflict == other.on_conflict
      end
    end
  end
end
