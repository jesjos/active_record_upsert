module Arel
  class OnConflictDoUpdateManager < Arel::TreeManager
    def initialize
      super
      @ast = Nodes::OnConflict.new
      @action = Nodes::DoUpdateSet.new
      @ast.action = @action
      @ctx = @ast
    end

    def target_condition= where
      @ast.where = where
    end

    def target= column
      @ast.target = column
    end

    def target(column)
      @ast.target = column
      self
    end

    def wheres= exprs
      @action.wheres = exprs
    end

    def where expr
      @action.wheres << expr
      self
    end

    def to_node
      @ast
    end

    def set values
      if String === values
        @action.values = [values]
      else
        @action.values = values.map { |column,value|
          Nodes::Assignment.new(
            Nodes::UnqualifiedColumn.new(column),
            value
          )
        }
      end
      self
    end
  end
end
