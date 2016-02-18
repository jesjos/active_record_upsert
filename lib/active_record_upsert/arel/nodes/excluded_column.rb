module Arel
  module Nodes
    class ExcludedColumn < Arel::Nodes::Node
      attr_reader :column
      def initialize(column)
        @column = column
      end
    end
  end
end
