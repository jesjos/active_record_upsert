module Arel
  module Nodes
    class DoUpdateSet < OnConflictAction
      attr_accessor :wheres, :values
      attr_accessor :key

      def initialize
        @wheres   = []
        @values   = []
        @key      = nil
      end

      def initialize_copy other
        super
        @wheres = @wheres.clone
        @values = @values.clone
      end

      def hash
        [@relation, @wheres, @values, @key].hash
      end

      def eql? other
        self.class == other.class &&
          self.relation == other.relation &&
          self.wheres == other.wheres &&
          self.values == other.values &&
          self.key == other.key
      end
      alias :== :eql?
    end
  end
end
