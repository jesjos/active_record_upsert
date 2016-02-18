module ActiveRecordUpsert
  module Arel
    module InsertManagerExtensions
      def on_conflict= node
        @ast.on_conflict = node
      end

      def do_nothing_on_conflict(target)
        @ast.on_conflict = Nodes::OnConflict.new.tap do |on_conflict|
          on_conflict.target = target
          on_conflict.action = Nodes::DoNothing.new
        end
      end
    end

    ::Arel::InsertManager.include(InsertManagerExtensions)
  end
end
