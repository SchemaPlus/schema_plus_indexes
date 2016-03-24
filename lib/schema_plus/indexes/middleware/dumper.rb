module SchemaPlus::Indexes
  module Middleware
    module Dumper
      module Table

        def after(env)

          # move each column's index to its column, and remove them from the
          # list of indexes that AR would dump after the table.  Any left
          # over will still be dumped by AR.
          env.table.columns.each do |column|

            # first check for a single-column index
            if (index = env.table.indexes.find(&its.columns == [column.name]))
              column.options[:index] = index_options(env, column, index)
              env.table.indexes.delete(index)

            # then check for the first of a multi-column index
            elsif (index = env.table.indexes.find(&its.columns.first == column.name))
              column.options[:index] = index_options(env, column, index)
              env.table.indexes.delete(index)
            end

          end

        end

        def index_options(env, column, index)
          options = {}
          options[:name] = index.name
          options[:with] = (index.columns - [column.name]) if index.columns.length > 1
          options.merge index.options
        end
      end
    end
  end
end
