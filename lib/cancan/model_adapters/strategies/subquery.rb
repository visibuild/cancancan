module CanCan
  module ModelAdapters
    class Strategies
      class Subquery < Base
        def execute!
          build_joins_relation_subquery(where_conditions)
        end

        def build_joins_relation_subquery(where_conditions)
          inner = model_class.unscoped do
            model_class.left_joins(joins).where(*where_conditions)
          end

          if model_class.primary_key.is_a?(Array)
            model_class.where(build_composite_key_where(inner))
          else
            model_class.where(model_class.primary_key => inner)
          end
        end

        def build_composite_key_where(inner)
          keys = model_class.primary_key.join(',')
          subquery = inner.select(model_class.primary_key).to_sql
          "(#{keys}) IN (#{subquery})"
        end
      end
    end
  end
end
