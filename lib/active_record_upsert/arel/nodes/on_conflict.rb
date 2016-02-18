module Arel
  module Nodes
    class OnConflict < Node
      attr_accessor :target, :action

      def initialize
        super
        @target = nil
        @action = nil
      end

      def hash
        [@target, @action].hash
      end

      def eql? other
        self.class == other.class &&
          self.target == other.target &&
          self.update_statement == other.update_statement
      end
    end
  end
end
